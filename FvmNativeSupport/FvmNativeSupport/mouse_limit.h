#pragma once
// ============================================================================
// mouse_limit.h — 高回报率鼠标输入限频
// ============================================================================
//
// 问题
//   高回报率鼠标（如 8 kHz）会向游戏窗口灌入大量 WM_MOUSEMOVE。实测 8 kHz 设备：
//   draw 阶段单帧阻塞最高 380 ms（fps 降至 2.6），而同期 CPU 占用始终低于 17%，
//   即 runner 在等待，而不是在计算。
//
// 为什么使用低级钩子
//   GameMaker runner 通过自身的 PeekMessage 循环取消息，因此在窗口过程里丢弃消息
//   无法起到节流作用（已实测验证）。故改用系统级 WH_MOUSE_LL 钩子。该思路与
//   Ixeris（Minecraft 的同类修复）所用的 "buffered raw input + threaded event
//   polling" 一致。
//
// 机制
//   1. 钩子运行在独立线程上，该线程跑自己的消息循环（对应线程化事件轮询）；
//   2. 到达速度快于目标频率的移动事件被吞掉，只保留最新位置（对应缓冲）；
//   3. 另一个线程按目标频率用 SendInput 以绝对坐标重新注入该位置；
//   4. 注入事件的 flags 带 LLMHF_INJECTED，钩子据此放行，避免重入；
//   5. 按键、滚轮、中键等其它鼠标事件一律原样放行，不参与限频。
//
// 效果
//   应用侧（含 runner）看到的鼠标消息量降至目标频率。
//
// 低于目标频率时的行为
//   仅对快于目标频率的输入生效。等于或低于目标频率时，每条事件都能通过间隔检查、
//   原样放行——500 Hz 鼠标在 500 Hz 限制下逐条通过，不会变顿。
//
// 安全保证
//   1. 仅在游戏窗口处于前台时限频；鼠标移到其它程序上行为完全正常。
//   2. 注入线程连续超过 kStallMs（100 ms）未能成功注入时，钩子立即改为全部放行，
//      因此不会出现系统光标冻结。

#include <windows.h>
#include <mmsystem.h>  // timeBeginPeriod / timeEndPeriod（WIN32_LEAN_AND_MEAN 会将其排除）

#pragma comment(lib, "winmm.lib")  // timeBeginPeriod

namespace mouse_limit {

static const DWORD kStallMs = 100;
static volatile LONG g_run = 0;
static volatile LONG g_pending = 0;
static volatile LONG g_px = 0;
static volatile LONG g_py = 0;
static volatile LONG g_last_inject_ms = 0;
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
  SendInput(1, &in, sizeof(INPUT));
}

static LRESULT CALLBACK LowLevelProc(int nCode, WPARAM wParam, LPARAM lParam) {
  if (nCode == HC_ACTION && wParam == WM_MOUSEMOVE && g_interval > 0) {
    MSLLHOOKSTRUCT *ms = reinterpret_cast<MSLLHOOKSTRUCT *>(lParam);
    if (ms != nullptr && (ms->flags & LLMHF_INJECTED) == 0) {
      // 安全保证 1：仅在游戏窗口处于前台时限频
      if (g_game_hwnd != nullptr && GetForegroundWindow() == g_game_hwnd) {
        // 安全保证 2：仅在注入线程正常工作时才吞事件
        const DWORD now_ms = GetTickCount();
        if (now_ms - static_cast<DWORD>(g_last_inject_ms) <= kStallMs) {
          static LONGLONG last_pass = 0;
          LARGE_INTEGER now{};
          QueryPerformanceCounter(&now);
          if ((now.QuadPart - last_pass) < g_interval) {
            g_px = ms->pt.x;
            g_py = ms->pt.y;
            InterlockedExchange(&g_pending, 1);
            g_drop += 1.0;
            return 1;  // 吞掉：不派发本条移动
          }
          last_pass = now.QuadPart;
        }
      }
    }
  }
  g_pass += 1.0;
  return CallNextHookEx(g_hook, nCode, wParam, lParam);
}

static DWORD WINAPI InjectThread(LPVOID) {
  timeBeginPeriod(1);  // 提高定时器精度，使 Sleep(1) 接近 1 ms
  LONGLONG last = 0;
  while (InterlockedCompareExchange(&g_run, 1, 1) == 1) {
    Sleep(1);
    if (InterlockedCompareExchange(&g_pending, 0, 1) == 1) {
      LARGE_INTEGER now{};
      QueryPerformanceCounter(&now);
      if (g_interval <= 0 || (now.QuadPart - last) >= g_interval) {
        last = now.QuadPart;
        InjectAbs(g_px, g_py);
        g_injected += 1.0;
        InterlockedExchange(&g_last_inject_ms,
                            static_cast<LONG>(GetTickCount()));
      } else {
        InterlockedExchange(&g_pending, 1);  // 未达间隔，放回待注入标志
      }
    }
  }
  timeEndPeriod(1);
  return 0;
}

static DWORD WINAPI HookThread(LPVOID) {
  g_hook_tid = GetCurrentThreadId();
  g_hook = SetWindowsHookExW(WH_MOUSE_LL, LowLevelProc,
                             GetModuleHandleW(nullptr), 0);
  if (g_hook == nullptr) {
    InterlockedExchange(&g_run, 0);
    return 1;
  }
  MSG msg;
  while (InterlockedCompareExchange(&g_run, 1, 1) == 1 &&
         GetMessageW(&msg, nullptr, 0, 0) > 0) {
    TranslateMessage(&msg);
    DispatchMessageW(&msg);
  }
  if (g_hook != nullptr) {
    UnhookWindowsHookEx(g_hook);
    g_hook = nullptr;
  }
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
  g_interval = g_qpc_freq / static_cast<LONGLONG>(hz);
  InterlockedExchange(&g_last_inject_ms, static_cast<LONG>(GetTickCount()));
  InterlockedExchange(&g_run, 1);
  g_inject_thread = CreateThread(nullptr, 0, InjectThread, nullptr, 0, nullptr);
  g_hook_thread = CreateThread(nullptr, 0, HookThread, nullptr, 0, nullptr);
  for (int i = 0; i < 60 && g_hook == nullptr &&
                  InterlockedCompareExchange(&g_run, 1, 1) == 1;
       ++i) {
    Sleep(10);
  }
  return g_hook != nullptr ? 1 : 0;
}

static double Stop() {
  InterlockedExchange(&g_run, 0);
  if (g_hook_tid != 0)
    PostThreadMessageW(g_hook_tid, WM_QUIT, 0, 0);
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
