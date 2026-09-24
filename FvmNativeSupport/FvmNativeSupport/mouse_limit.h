#pragma once
// ============================================================================
// mouse_limit.h — 高回报率鼠标输入限频
// ============================================================================
//
// 问题
//   高回报率鼠标（如 8 kHz）每帧向窗口灌入数千条 WM_MOUSEMOVE。帧内 draw 阻塞最高
//   可达 380 ms，而同期 CPU 占用很低 —— runner 是在等待消息，不是在计算。
//
// 为什么用低级钩子
//   GameMaker runner 用自己的 PeekMessage 循环取消息，在窗口过程里丢弃消息挡不住它；
//   能拦在应用之前的只有系统级钩子，故用 WH_MOUSE_LL。
//
// 机制
//   1. 钩子运行在独立线程上，该线程跑自己的消息循环；
//   2. 到达速度快于目标频率的移动事件被吞掉；
//   3. 被吞掉的位移以「上次注入位置」为基准累加，到间隔点用 SendInput 以绝对坐标
//      一次性补发 —— 补回的是 100% 位移，与注入频率无关；
//   4. 注入事件带 LLMHF_INJECTED 标志，钩子据此放行，避免重入；
//   5. 按键、滚轮等其它鼠标事件一律原样放行，不参与限频。
//
// 效果
//   应用侧（含 runner）看到的鼠标消息量降至目标频率。
//
// 低于目标频率时的行为
//   只对快于目标频率的输入生效：等于或低于目标频率时每条事件都能通过间隔检查、原样
//   放行 —— 500 Hz 鼠标在 500 Hz 限制下逐条通过，不会变顿。
//
// 安全保证
//   1. 启停由 GML 侧按 window_has_focus() 控制，本模块不做任何前台/几何判断；
//   2. 注入线程心跳超过 kStallMs 未刷新即全部放行，系统光标不会被冻住。

#include <windows.h>
#include <mmsystem.h>  // timeBeginPeriod / timeEndPeriod（WIN32_LEAN_AND_MEAN 会将其排除）
#include <cstdarg>
#include <cstdio>
#include <fstream>
#include <string>

#pragma comment(lib, "winmm.lib")  // timeBeginPeriod

// 高精度可等待定时器标志（Win10 1803+；旧 SDK 头里可能没有）
#ifndef CREATE_WAITABLE_TIMER_HIGH_RESOLUTION
#define CREATE_WAITABLE_TIMER_HIGH_RESOLUTION 0x00000002
#endif

namespace mouse_limit {

// 安全网阈值：注入线程心跳超过该时长未刷新即视为其已停摆，钩子转为全部放行。
// 取 300 ms 是为了让满载下的调度抖动不至于被误判。
static const DWORD kStallMs = 300;
static volatile LONG g_run = 0;
static volatile LONG g_px = 0;
static volatile LONG g_py = 0;
static HHOOK g_hook = nullptr;
static DWORD g_hook_tid = 0;
static HANDLE g_hook_thread = nullptr;
static HANDLE g_inject_thread = nullptr;
static LONGLONG g_interval = 0;
static LONGLONG g_qpc_freq = 0;
static HWND g_game_hwnd = nullptr;
static double g_drop = 0;
static double g_pass = 0;
static double g_injected = 0;
static double g_inj_fail = 0;  // SendInput 返回 0 的次数（失败 = 这一下光标不会动）
static double g_stale = 0;  // 因心跳过期（安全网判“注入线程已死”）而放行的条数

// 位移累加器：只由钩子线程读写（详见 LowLevelProc 里的说明）。
static LONG g_cur_x = 0;  // 我们已知的光标真实位置 = 上次注入的位置
static LONG g_cur_y = 0;
static LONGLONG g_acc_dx = 0;  // 自上次注入以来累加的真实位移
static LONGLONG g_acc_dy = 0;
static LONGLONG g_last_inj_qpc = 0;
static DWORD g_game_pid = 0;        // 游戏进程号（Start 时取，仅供诊断打印）
// 诊断计数器：每条 return 路径各有一个计数，便于区分是哪一步放行的。
static double g_arrive = 0;    // 钩子被调用总次数
static double g_notmove = 0;   // 非 HC_ACTION / 非 WM_MOUSEMOVE / 未启动
static double g_inj_seen = 0;  // 带 LLMHF_INJECTED 的（我们自己注入的）

// ---------------------------------------------------------------------------
// 诊断日志：%LOCALAPPDATA%\FVM_Reborn\native\mouse_limit.log
// 每 5 秒落一行计数（吞 / 放行 / 注入 / 钩子状态），写不进去就静默跳过。
// ---------------------------------------------------------------------------
static char g_log_path[MAX_PATH] = {0};
static bool g_log_checked = false;

static void EnsureLogPath() {
  if (g_log_checked)
    return;
  g_log_checked = true;
  char base[MAX_PATH] = {0};
  const DWORD n = GetEnvironmentVariableA("LOCALAPPDATA", base, MAX_PATH);
  if (n == 0 || n >= MAX_PATH)
    return;
  const std::string root = std::string(base) + "\\FVM_Reborn";
  const std::string dir = root + "\\native";
  CreateDirectoryA(root.c_str(), nullptr);
  CreateDirectoryA(dir.c_str(), nullptr);
  const std::string path = dir + "\\mouse_limit.log";
  if (path.size() < MAX_PATH)
    lstrcpyA(g_log_path, path.c_str());
}

static void LogF(const char *fmt, ...) {
  EnsureLogPath();
  if (g_log_path[0] == 0)
    return;
  std::ofstream f(g_log_path, std::ios::app);
  if (!f)
    return;
  SYSTEMTIME st{};
  GetLocalTime(&st);
  char body[1024] = {0};
  va_list ap;
  va_start(ap, fmt);
  _vsnprintf_s(body, sizeof(body), _TRUNCATE, fmt, ap);
  va_end(ap);
  char stamp[32] = {0};
  _snprintf_s(stamp, sizeof(stamp), _TRUNCATE, "%02u:%02u:%02u", st.wHour,
              st.wMinute, st.wSecond);
  f << stamp << "  " << body << "\n";
}

static void EnsureFreq() {
  if (g_qpc_freq == 0) {
    LARGE_INTEGER f{};
    QueryPerformanceFrequency(&f);
    g_qpc_freq = f.QuadPart;
  }
}

static void InjectAbs(LONG x, LONG y) {
  const int vx = GetSystemMetrics(SM_XVIRTUALSCREEN);
  const int vy = GetSystemMetrics(SM_YVIRTUALSCREEN);
  const int vw = GetSystemMetrics(SM_CXVIRTUALSCREEN);
  const int vh = GetSystemMetrics(SM_CYVIRTUALSCREEN);
  if (vw <= 1 || vh <= 1)
    return;
  INPUT in{};
  in.type = INPUT_MOUSE;
  in.mi.dwFlags =
      MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE | MOUSEEVENTF_VIRTUALDESK;
  in.mi.dx = static_cast<LONG>(((x - vx) * 65535.0) / (vw - 1) + 0.5);
  in.mi.dy = static_cast<LONG>(((y - vy) * 65535.0) / (vh - 1) + 0.5);
  if (SendInput(1, &in, sizeof(INPUT)) == 0) {
    g_inj_fail += 1.0;  // 失败 = 这一下光标不会动（注入次数直接等于灵敏度）
  }
}

// 注入线程心跳：由 InjectThread 每轮循环【无条件】刷新。安全网据此判断该线程是否存活，
// 因此不能在注入成功时才刷新 —— 玩家短暂停手会让时间戳越过 kStallMs 并永久过期，
// 安全网随即闩死在全放行。
static volatile LONG g_inject_tick = 0;

// 本模块不做任何前台/几何判断：玩家是否在游戏里由 GML 侧用 window_has_focus() 决定
// （有焦点才 Start，失焦即 Stop）。这里只在 g_interval > 0 且心跳新鲜时限频。
// 放行的这条移动会由系统真正送达，光标随即处于 ms->pt，位移累加的基准必须跟着挪。
// 否则这条放行造成的偏移会被之后每一条被吞事件重复计入（乘法放大）→ 光标卡顿/跳动。
// 注意【只换基准，不动 g_acc】：g_acc 是「尚欠玩家的位移」，换个参照系依旧有效；
// 若把它清零，等于吞掉这段真实位移，光标会系统性滞后。
// 自己注入的事件 pt 恰等于 g_cur，本调用退化为无操作 —— 正常路径行为完全不变。
static void RebaseTo(const MSLLHOOKSTRUCT *ms) {
  g_cur_x = ms->pt.x;
  g_cur_y = ms->pt.y;
}

static LRESULT CALLBACK LowLevelProc(int nCode, WPARAM wParam, LPARAM lParam) {
  g_arrive += 1.0;
  if (nCode != HC_ACTION || wParam != WM_MOUSEMOVE || g_interval <= 0) {
    g_notmove += 1.0;
    g_pass += 1.0;
    return CallNextHookEx(g_hook, nCode, wParam, lParam);
  }
  MSLLHOOKSTRUCT *ms = reinterpret_cast<MSLLHOOKSTRUCT *>(lParam);
  if (ms == nullptr || (ms->flags & LLMHF_INJECTED) != 0) {
    g_inj_seen += 1.0;  // 我们自己注入的事件，绝不能再吞（否则自我循环）
    if (ms != nullptr)
      RebaseTo(ms);  // 本事件已放行，基准必须跟随，否则偏移被重复累加
    g_pass += 1.0;
    return CallNextHookEx(g_hook, nCode, wParam, lParam);
  }
  // 安全网：只有心跳新鲜才吞事件。注入线程真死了 → 心跳过期 → 全放行，
  // 保证系统鼠标不会被冻住。
  const DWORD now_ms = GetTickCount();
  if (now_ms - static_cast<DWORD>(g_inject_tick) > kStallMs) {
    g_stale += 1.0;
    RebaseTo(ms);  // 本条被放行，同上：基准跟随，避免恢复限频后带着旧偏移继续累加
    g_pass += 1.0;
    return CallNextHookEx(g_hook, nCode, wParam, lParam);
  }
  // ── 核心：累加被吞掉的位移，按间隔一次性补发 ────────────────────────────────
  // return 1 会把这条事件的位移真正丢掉，而 ms->pt 永远只比「当前光标」超前【一个】
  // 位移。所以直接注入 pt 等于每次注入只补回一个位移：
  //     有效位移 = 注入次数 / 轮询率 × 原始位移
  // 正确做法是以「我们上次注入的位置」为基准把每个位移累加起来，注入时发累加后的
  // 真实位置 —— 补回 100% 位移，与注入频率无关。
  g_px = ms->pt.x;  // 仅供日志诊断
  g_py = ms->pt.y;
  g_acc_dx += static_cast<LONGLONG>(ms->pt.x) - g_cur_x;
  g_acc_dy += static_cast<LONGLONG>(ms->pt.y) - g_cur_y;
  LARGE_INTEGER now_qpc{};
  QueryPerformanceCounter(&now_qpc);
  if (g_last_inj_qpc == 0)
    g_last_inj_qpc = now_qpc.QuadPart;
  if (g_interval > 0 && (now_qpc.QuadPart - g_last_inj_qpc) >= g_interval) {
    g_cur_x += static_cast<LONG>(g_acc_dx);
    g_cur_y += static_cast<LONG>(g_acc_dy);
    g_acc_dx = 0;
    g_acc_dy = 0;
    InjectAbs(g_cur_x, g_cur_y);  // 绝对坐标：绕过指针加速，位置精确
    g_injected += 1.0;
    g_last_inj_qpc = now_qpc.QuadPart;
  }
  g_drop += 1.0;
  return 1;  // 吞掉：不派发本条移动（位移已在上面累加）
}

static DWORD WINAPI InjectThread(LPVOID) {
  // 该线程是安全网心跳的刷新者，被游戏线程饿住会让安全网误判它已死。
  // 只提到 HIGHEST，不用 TIME_CRITICAL（避免反过来抢游戏 CPU）。
  SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_HIGHEST);
  timeBeginPeriod(1);  // 提高定时器精度，使 Sleep(1) 接近 1 ms
  LogF("inject 线程启动");
  LONGLONG last = 0;
  DWORD last_log = GetTickCount();
  // 高精度可等待定时器（Win10 1803+）：补回位移的完整度取决于注入速率，
  // Sleep(1) 的精度不足以打满目标频率，故用 1 ms 周期定时器。
  HANDLE timer = CreateWaitableTimerExW(
      nullptr, nullptr, CREATE_WAITABLE_TIMER_HIGH_RESOLUTION, TIMER_ALL_ACCESS);
  if (timer != nullptr) {
    LARGE_INTEGER due{};
    due.QuadPart = -10000LL;  // 1ms（100ns 单位，负值 = 相对时间）
    SetWaitableTimer(timer, &due, 1, nullptr, nullptr, FALSE);  // 周期 1ms
  }
  LARGE_INTEGER now{};
  QueryPerformanceCounter(&now);
  last = now.QuadPart;
  while (InterlockedCompareExchange(&g_run, 1, 1) == 1) {
    if (timer != nullptr) {
      WaitForSingleObject(timer, 4);
    } else {
      Sleep(1);
    }
    // 心跳：无论这一轮有没有真的注入，都刷新（安全网判据，见 LowLevelProc）
    InterlockedExchange(&g_inject_tick, static_cast<LONG>(GetTickCount()));
    QueryPerformanceCounter(&now);
    last = now.QuadPart;
    // 注入在钩子线程内完成：位移累加的基准 g_cur_x/g_cur_y 若被两个线程同时读写，
    // 位移会被算重或算漏。本线程只负责心跳与 5 秒统计。
    if (GetTickCount() - last_log >= 5000) {
      last_log = GetTickCount();
      POINT curpoint{};
      GetCursorPos(&curpoint);
      LogF("统计 吞=%.0f 放行=%.0f 注入=%.0f 注入失败=%.0f | 到达=%.0f 非移动=%.0f 注入事件=%.0f 心跳过期=%.0f | 钩子=%d 事件位置=(%ld,%ld) 注入位置=(%ld,%ld) 实际光标=(%ld,%ld) 前台=%p 游戏=%p",
           g_drop, g_pass, g_injected, g_inj_fail, g_arrive, g_notmove,
           g_inj_seen, g_stale, g_hook != nullptr ? 1 : 0,
           static_cast<long>(g_px), static_cast<long>(g_py),
           static_cast<long>(g_cur_x), static_cast<long>(g_cur_y),
           static_cast<long>(curpoint.x), static_cast<long>(curpoint.y),
           static_cast<void *>(GetForegroundWindow()),
           static_cast<void *>(g_game_hwnd));
    }
  }
  if (timer != nullptr)
    CloseHandle(timer);
  timeEndPeriod(1);
  LogF("inject 线程退出 吞=%.0f 放行=%.0f 注入=%.0f", g_drop, g_pass, g_injected);
  return 0;
}

static DWORD WINAPI HookThread(LPVOID) {
  g_hook_tid = GetCurrentThreadId();
  // 钩子句柄存在局部变量里，只卸自己装的那一个：Stop→Start 快速交替时，按全局
  // g_hook 去卸会误卸掉新装好的钩子。
  HHOOK h = SetWindowsHookExW(WH_MOUSE_LL, LowLevelProc,
                              GetModuleHandleW(nullptr), 0);
  if (h == nullptr) {
    InterlockedExchange(&g_run, 0);
    return 1;
  }
  g_hook = h;
  MSG msg;
  while (InterlockedCompareExchange(&g_run, 1, 1) == 1 &&
         GetMessageW(&msg, nullptr, 0, 0) > 0) {
    TranslateMessage(&msg);
    DispatchMessageW(&msg);
  }
  UnhookWindowsHookEx(h);
  if (g_hook == h)
    g_hook = nullptr;
  return 0;
}

/**
 * @brief 启动输入限频。
 * @param hz   目标频率（上限 1000，建议 500）；<= 0 时直接返回 0 不启动。
 * @param hwnd 游戏窗口句柄；为 nullptr 时取当前前台窗口。
 * @return 1 = 启动成功，0 = 失败（例如钩子安装失败）。
 * @note 等于或低于 hz 的输入原样放行，仅高于 hz 的移动会被合并。
 */
static double Start(double hz, HWND hwnd) {
  EnsureFreq();
  if (hz <= 0)
    return 0;
  if (hz > 1000)
    hz = 1000;
  if (InterlockedCompareExchange(&g_run, 1, 1) == 1)
    return 1;  // 已经启动
  g_game_hwnd = hwnd != nullptr ? hwnd : GetForegroundWindow();
  g_game_pid = 0;
  if (g_game_hwnd != nullptr)
    GetWindowThreadProcessId(g_game_hwnd, &g_game_pid);
  g_interval = g_qpc_freq / static_cast<LONGLONG>(hz);
  InterlockedExchange(&g_inject_tick, static_cast<LONG>(GetTickCount()));
  InterlockedExchange(&g_run, 1);
  // 位移累加的基准 = 启动时光标的真实位置；心跳同时置位，钩子自启动起即可开始吞事件。
  POINT pt{};
  if (GetCursorPos(&pt)) {
    g_px = pt.x;
    g_py = pt.y;
    g_cur_x = pt.x;  // 位移累加的基准 = 注入前光标的真实位置
    g_cur_y = pt.y;
  }
  g_acc_dx = 0;
  g_acc_dy = 0;
  g_last_inj_qpc = 0;
  // 心跳线程刷新 g_inject_tick 并输出统计；节流与注入都在钩子线程内完成
  // （位移累加的基准必须单线程读写，见 LowLevelProc）。
  g_inject_thread = CreateThread(nullptr, 0, InjectThread, nullptr, 0, nullptr);
  g_hook_thread = CreateThread(nullptr, 0, HookThread, nullptr, 0, nullptr);
  for (int i = 0; i < 60 && g_hook == nullptr &&
                  InterlockedCompareExchange(&g_run, 1, 1) == 1;
       ++i) {
    Sleep(10);
  }
  const double interval_ms =
      g_qpc_freq > 0
          ? (static_cast<double>(g_interval) * 1000.0 /
             static_cast<double>(g_qpc_freq))
          : 0.0;
  LogF("Start 目标=%.0fHz 间隔=%.3fms 游戏窗口=%p(pid=%lu) 当前前台=%p 光标下=%p 钩子=%d",
       hz, interval_ms, static_cast<void *>(g_game_hwnd), g_game_pid,
       static_cast<void *>(GetForegroundWindow()),
       static_cast<void *>(WindowFromPoint(pt)), g_hook != nullptr ? 1 : 0);
  return g_hook != nullptr ? 1 : 0;
}

static double Stop() {
  InterlockedExchange(&g_inject_tick, 0);  // 心跳归零 → 钩子立刻转为全放行
  InterlockedExchange(&g_run, 0);
  g_interval = 0;  // 即使钩子还没卸干净，也不再有事件被吞
  if (g_hook_tid != 0)
    PostThreadMessageW(g_hook_tid, WM_QUIT, 0, 0);
  LogF("Stop 吞=%.0f 放行=%.0f 注入=%.0f", g_drop, g_pass, g_injected);
  // 不要在这里等待线程退出：Stop() 由游戏主线程调用，等待会卡住整帧。
  // 线程自己看 g_run 退出，钩子由 HookThread 用局部句柄卸自己那一个；句柄直接关。
  if (g_hook_thread != nullptr) {
    CloseHandle(g_hook_thread);
    g_hook_thread = nullptr;
  }
  if (g_inject_thread != nullptr) {
    CloseHandle(g_inject_thread);
    g_inject_thread = nullptr;
  }
  g_hook_tid = 0;
  g_hook = nullptr;
  return 0;
}

/**
 * @brief 读取累计计数。
 * @param which 1 = 被吞掉的移动条数，2 = 放行条数，3 = 重新注入条数。
 * @return 对应计数；which 非法时返回 0。
 */
static double Stats(double which) {
  if (which == 1)
    return g_drop;
  if (which == 2)
    return g_pass;
  if (which == 3)
    return g_injected;
  return 0;
}

}  // namespace mouse_limit
