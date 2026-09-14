#pragma once
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif

#include <cstdio>
#include <cwchar>
#include <cwctype>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string.h>
#include <string>
#include <vector>


#include "archive_extractor.h"
#include "file_system.h"
#include "json.hpp"
#include "typedef.h"

#include <commctrl.h>
#include <imm.h>
#include <msctf.h>


#pragma comment(lib, "comctl32.lib")

// IME 屏蔽心跳：用窗口定时器自持 1 秒重压。
// v5 的心跳挂在 obj_game_init 上，而该对象只在 room_init 存在且非持久 →
// 进游戏后循环就死了
static const UINT_PTR kImeTimerId = 0x494D; // 'MI'
static bool g_ime_block_active = true;

static void ApplyImeBlock(HWND hwnd, bool from_timer);

// v7.3：屏蔽是「可开关」的——游戏内输入框获得焦点时必须能放开（否则玩家打不了中文）。
//       所以摘掉 IME 上下文前先把原 HIMC 存下来，放开时原样挂回（见文件末尾
//       ApplyImeEnable）。
static HIMC g_ime_saved_himc = nullptr;
static HWND g_ime_blocked_hwnd = nullptr;
static HWND g_ime_timer_hwnd = nullptr;

// 按窗口子类化：拦截 IME 相关消息 + 处理 IME 屏蔽心跳
LRESULT CALLBACK ImeWndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam,
                            UINT_PTR uIdSubclass, DWORD_PTR dwRefData) {
  switch (msg) {
  case WM_IME_SETCONTEXT:
    // 文档化做法：清掉「显示合成窗/候选窗/引导线」标志，其余交给 DefWindowProc
    lParam &= ~static_cast<LPARAM>(ISC_SHOWUIALL);
    break;
  case WM_IME_STARTCOMPOSITION:
  case WM_IME_COMPOSITION:
  case WM_IME_ENDCOMPOSITION:
  case WM_IME_CONTROL:
  case WM_IME_NOTIFY:
  case WM_IME_REQUEST:
  case WM_IME_SELECT:
    // 丢弃合成/候选消息；不碰 WM_IME_CHAR / WM_CHAR / WM_KEYDOWN，避免影响打字
    return 0;
  case WM_SETFOCUS:
  case WM_ACTIVATE:
    // 窗口重新获得焦点时系统可能把 IME 上下文挂回来 →
    // 立刻再断开（只影响本窗口）
    if (msg != WM_ACTIVATE || wParam != WA_INACTIVE) {
      ImmAssociateContext(hwnd, nullptr);
    }
    break;
  case WM_TIMER:
    if (wParam == kImeTimerId) {
      ApplyImeBlock(hwnd, true);
      return 0;
    }
    break;
  }
  return DefSubclassProc(hwnd, msg, wParam, lParam);
}
#pragma comment(lib, "imm32.lib")

using json = nlohmann::json;

inline void LogNativeError(int error_code, const char *message) {
  const auto &path = NativeLogFilePath();
  if (path.empty()) {
    return;
  }

  const std::filesystem::path log_path(FileSystem::Utf8ToUtf16(path.c_str()));
  // 确保日志目录存在：否则 ofstream 打开失败会静默丢日志（v5 的潜在坑）
  std::error_code ec;
  std::filesystem::create_directories(log_path.parent_path(), ec);

  std::ofstream ofs(log_path, std::ios::app);
  if (!ofs.is_open()) {
    return;
  }

  ofs << "[error_code=" << error_code << "] " << (message ? message : "")
      << '\n';
}

inline auto FailWith(int error_code, const char *message) -> double {
  LogNativeError(error_code, message);
  return static_cast<double>(error_code);
}

/**
 * @brief 设置 native 错误日志文件路径。成功返回 0。
 */
GmlCallable auto SetNativeLogFilePath(const char *log_file_path) -> double {
  if (!log_file_path || !*log_file_path) {
    return FailWith(NativeError::InvalidArgument,
                    "SetNativeLogFilePath: empty log_file_path");
  }
  NativeLogFilePath() = log_file_path;
  // 提前建目录，保证后续 LogNativeError 一定写得进去
  std::error_code ec;
  std::filesystem::create_directories(
      std::filesystem::path(FileSystem::Utf8ToUtf16(log_file_path))
          .parent_path(),
      ec);
  return static_cast<double>(NativeError::Ok);
}

/**
 * @brief 打开文件夹。成功返回 0，失败返回 ShellExecute 错误码。
 */
GmlCallable auto OpenFolder(const char *path) -> double {
  if (!path || !*path) {
    return FailWith(NativeError::InvalidArgument, "OpenFolder: empty path");
  }
  int code = FileSystem::OpenFolder(path);
  if (code != 0) {
    return FailWith(code, "OpenFolder failed");
  }
  return static_cast<double>(NativeError::Ok);
}

/**
 * @brief 检查文件夹是否存在 (1为真, 0为假)
 */
GmlCallable auto FolderExists(const char *path) -> double {
  return FileSystem::FolderExists(path) ? 1.0 : 0.0;
}

/**
 * @brief 检查文件是否存在 (1为真, 0为假)
 */
GmlCallable auto FileExists(const char *path) -> double {
  return FileSystem::FileExists(path) ? 1.0 : 0.0;
}

/**
 * @brief 复制并合并文件夹。成功返回 0，失败返回平台错误码。
 */
GmlCallable auto CopyFolder(const char *source, const char *destination)
    -> double {
  if (!source || !*source || !destination || !*destination) {
    return FailWith(NativeError::InvalidArgument,
                    "CopyFolder: empty source or destination");
  }
  int code = FileSystem::CopyAndMergeDirectory(source, destination);
  if (code != 0) {
    return FailWith(code, "CopyFolder failed");
  }
  return static_cast<double>(NativeError::Ok);
}

/**
 * @brief 删除指定文件夹及其内容。成功返回 0，失败返回 SHFileOperation 错误码。
 */
GmlCallable auto DeleteFolder(const char *path) -> double {
  if (!path || !*path) {
    return FailWith(NativeError::InvalidArgument, "DeleteFolder: empty path");
  }
  int code = FileSystem::DeleteFolder(path);
  if (code != 0) {
    return FailWith(code, "DeleteFolder failed");
  }
  return static_cast<double>(NativeError::Ok);
}

GmlCallable auto StartBackupWithTargetFile(const char *saves_dir,
                                           const char *target_file) -> double {
  if (!saves_dir || !*saves_dir || !target_file || !*target_file) {
    return FailWith(
        NativeError::InvalidArgument,
        "StartBackupWithTargetFile: empty saves_dir or target_file");
  }

  namespace fs = std::filesystem;
  std::wstring w_saves_dir = FileSystem::Utf8ToUtf16(saves_dir);

  std::error_code ec;
  if (!fs::exists(w_saves_dir, ec)) {
    if (ec) {
      return FailWith(ec.value(),
                      "StartBackupWithTargetFile: exists check failed");
    }
    fs::create_directories(w_saves_dir, ec);
    if (ec) {
      return FailWith(ec.value(),
                      "StartBackupWithTargetFile: create_directories failed");
    }
  }

  json backup_json;
  backup_json["files"] = json::array();

  for (const auto &entry : fs::directory_iterator(w_saves_dir, ec)) {
    if (entry.path().extension() == L".json") {
      std::ifstream ifs(entry.path());
      if (ifs.is_open()) {
        std::stringstream buffer;
        buffer << ifs.rdbuf();
        ifs.close();

        json file_entry;
        file_entry["name"] = entry.path().filename().string();
        file_entry["content"] = buffer.str();
        backup_json["files"].push_back(file_entry);
      }
    }
  }

  if (ec) {
    return FailWith(ec.value(),
                    "StartBackupWithTargetFile: directory iteration error");
  }

  std::string json_str = backup_json.dump(4);
  std::vector<uint8_t> data(json_str.begin(), json_str.end());

  int write_code = FileSystem::WriteNativeFile(target_file, data);
  if (write_code != 0) {
    return FailWith(write_code, "StartBackupWithTargetFile: write failed");
  }
  return static_cast<double>(NativeError::Ok);
}

GmlCallable auto StartBackup(const char *saves_dir) -> double {
  if (!saves_dir || !*saves_dir) {
    return FailWith(NativeError::InvalidArgument,
                    "StartBackup: empty saves_dir");
  }
  std::string saves_dir_copy(saves_dir);

  std::string chosen_folder = FileSystem::ChooseFolder();
  if (chosen_folder.empty()) {
    return FailWith(NativeError::OperationCancelled,
                    "StartBackup: folder dialog cancelled");
  }

  namespace fs = std::filesystem;
  std::wstring w_chosen = FileSystem::Utf8ToUtf16(chosen_folder.c_str());
  fs::path backup_path = fs::path(w_chosen) / L"backup.json";
  std::string backup_path_str =
      FileSystem::Utf16ToUtf8(backup_path.wstring().c_str());
  if (backup_path_str.empty()) {
    return FailWith(NativeError::EncodingFailed,
                    "StartBackup: path encoding failed");
  }

  return StartBackupWithTargetFile(saves_dir_copy.c_str(),
                                   backup_path_str.c_str());
}

GmlCallable auto RestoreBackupWithTargetFile(const char *saves_dir,
                                             const char *target_file)
    -> double {
  if (!saves_dir || !*saves_dir || !target_file || !*target_file) {
    return FailWith(
        NativeError::InvalidArgument,
        "RestoreBackupWithTargetFile: empty saves_dir or target_file");
  }

  namespace fs = std::filesystem;
  std::wstring w_target = FileSystem::Utf8ToUtf16(target_file);
  std::error_code ec;
  if (!fs::exists(w_target, ec)) {
    return FailWith(ec ? ec.value() : ERROR_FILE_NOT_FOUND,
                    "RestoreBackupWithTargetFile: target file not found");
  }

  std::ifstream ifs(w_target);
  if (!ifs.is_open()) {
    return FailWith(ERROR_FILE_NOT_FOUND,
                    "RestoreBackupWithTargetFile: failed to open target file");
  }
  std::stringstream buffer;
  buffer << ifs.rdbuf();
  ifs.close();

  json backup_json;
  try {
    backup_json = json::parse(buffer.str());
  } catch (...) {
    return FailWith(NativeError::JsonParseFailed,
                    "RestoreBackupWithTargetFile: json parse failed");
  }

  std::wstring w_saves_dir = FileSystem::Utf8ToUtf16(saves_dir);
  fs::create_directories(w_saves_dir, ec);
  if (ec) {
    return FailWith(ec.value(),
                    "RestoreBackupWithTargetFile: create_directories failed");
  }

  if (!backup_json.contains("files") || !backup_json["files"].is_array()) {
    return FailWith(NativeError::JsonParseFailed,
                    "RestoreBackupWithTargetFile: missing files array");
  }

  for (const auto &file_entry : backup_json["files"]) {
    if (!file_entry.contains("name") || !file_entry.contains("content")) {
      return FailWith(NativeError::JsonParseFailed,
                      "RestoreBackupWithTargetFile: invalid file entry");
    }
    std::string name = file_entry["name"];
    std::string content = file_entry["content"];

    fs::path file_path =
        fs::path(w_saves_dir) / FileSystem::Utf8ToUtf16(name.c_str());

    std::vector<uint8_t> data(content.begin(), content.end());
    std::string file_path_utf8 =
        FileSystem::Utf16ToUtf8(file_path.wstring().c_str());
    if (file_path_utf8.empty()) {
      return FailWith(NativeError::EncodingFailed,
                      "RestoreBackupWithTargetFile: path encoding failed");
    }
    int write_code = FileSystem::WriteNativeFile(file_path_utf8, data);
    if (write_code != 0) {
      return FailWith(write_code,
                      "RestoreBackupWithTargetFile: write file failed");
    }
  }

  return static_cast<double>(NativeError::Ok);
}

GmlCallable auto RestoreBackup(const char *saves_dir,
                               const char *default_backup_dir) -> double {
  std::string saves_dir_copy = (saves_dir && *saves_dir) ? saves_dir : "";
  std::string default_dir_copy =
      (default_backup_dir && *default_backup_dir) ? default_backup_dir : "";

  if (saves_dir_copy.empty()) {
    return FailWith(NativeError::InvalidArgument,
                    "RestoreBackup: empty saves_dir");
  }

  std::string chosen_file = FileSystem::ChooseFileToOpen(
      default_dir_copy.empty() ? nullptr : default_dir_copy.c_str());
  if (chosen_file.empty()) {
    return FailWith(NativeError::OperationCancelled,
                    "RestoreBackup: file dialog cancelled");
  }

  return RestoreBackupWithTargetFile(saves_dir_copy.c_str(),
                                     chosen_file.c_str());
}

// [v7.2 已删除] 候选窗类名/进程名关键字表 + EqualsNoCaseN/ContainsNoCase。
// 删除原因（线上事故）：表里有 L"WeChat"/L"Weixin"，而 MatchesImeKeys 对类名是
//   **无条件子串匹配**，于是微信主窗口（类名
//   WeChatMainWndForPC）被判成"候选窗"， 被 HideImeCandidateProc 每秒
//   ShowWindow(SW_HIDE) → 微信一启动就被"清掉"。 该隐藏链路对 v7 毫无贡献（v7
//   生效靠 HIMC 断开，hidden 恒为 0），故整条移除。

static void GetProcessBaseNameW(DWORD pid, wchar_t *out, size_t cch) {
  if (!out || cch == 0)
    return;
  out[0] = L'\0';
  if (!pid)
    return;
  HANDLE handle = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
  if (!handle)
    return;
  wchar_t full[MAX_PATH] = {0};
  DWORD len = MAX_PATH;
  if (QueryFullProcessImageNameW(handle, 0, full, &len) && len > 0) {
    const wchar_t *base = wcsrchr(full, L'\\');
    wcsncpy_s(out, cch, base ? base + 1 : full, _TRUNCATE);
  }
  CloseHandle(handle);
}

static std::string WideToUtf8(const wchar_t *w) {
  if (!w || !*w)
    return std::string();
  const int n =
      WideCharToMultiByte(CP_UTF8, 0, w, -1, nullptr, 0, nullptr, nullptr);
  if (n <= 1)
    return std::string();
  std::string s(static_cast<size_t>(n - 1), '\0');
  WideCharToMultiByte(CP_UTF8, 0, w, -1, s.data(), n, nullptr, nullptr);
  return s;
}

// 诊断：把「可见顶层窗口」的增量写进 latest.log，用来拿真实候选窗类名与宿主进程
struct ImeSnapCtx {
  HWND game;
  HWND fg;
  std::wstring sig;
  std::vector<std::wstring> lines;
};

static BOOL CALLBACK SnapshotProc(HWND wnd, LPARAM lParam) {
  ImeSnapCtx *ctx = reinterpret_cast<ImeSnapCtx *>(lParam);
  if (!wnd || wnd == ctx->game)
    return TRUE;
  if (!IsWindowVisible(wnd))
    return TRUE;
  wchar_t cls[256] = {0};
  if (!GetClassNameW(wnd, cls, 255))
    return TRUE;
  wchar_t title[128] = {0};
  GetWindowTextW(wnd, title, 127);
  DWORD pid = 0;
  GetWindowThreadProcessId(wnd, &pid);
  wchar_t proc[MAX_PATH] = {0};
  GetProcessBaseNameW(pid, proc, MAX_PATH);
  ctx->sig += cls;
  ctx->sig += L'|';
  ctx->sig += std::to_wstring(pid);
  ctx->sig += L';';
  std::wstring line = L"ImeDbg: cls=";
  line += cls;
  line += L" proc=";
  line += proc;
  line += L" pid=";
  line += std::to_wstring(pid);
  if (wnd == ctx->fg)
    line += L" fg=1";
  if (title[0]) {
    line += L" title=";
    line += title;
  }
  ctx->lines.push_back(line);
  return TRUE;
}

// 窗口快照：只在 FVM_IME_DEBUG=1 时输出，平时不写（避免 latest.log 无限增长）
static void LogImeWindowSnapshot(HWND game, bool full) {
  if (!full)
    return;
  ImeSnapCtx ctx{};
  ctx.game = game;
  ctx.fg = GetForegroundWindow();
  EnumWindows(SnapshotProc, reinterpret_cast<LPARAM>(&ctx));
  char head[160] = {0};
  sprintf_s(head, sizeof(head), "ImeDbg: snapshot n=%d full=1",
            static_cast<int>(ctx.lines.size()));
  LogNativeError(0, head);
  int shown = 0;
  for (const std::wstring &line : ctx.lines) {
    if (++shown > 60) {
      LogNativeError(0, "ImeDbg: ... (truncated)");
      break;
    }
    LogNativeError(0, WideToUtf8(line.c_str()).c_str());
  }
}

// 全量模式：设环境变量 FVM_IME_DEBUG 为非空值（如 "1"）才输出窗口快照，不依赖
// GML。 注意：不能只判断长度>0——空字符串会导致误判为真，必须要求"存在且非空"。
static bool ImeDebugEnvSet() {
  wchar_t buf[8] = {0};
  const DWORD len = GetEnvironmentVariableW(L"FVM_IME_DEBUG", buf,
                                            static_cast<DWORD>(std::size(buf)));
  if (len == 0)
    return false; // 不存在
  if (len >= static_cast<DWORD>(std::size(buf)))
    return *buf != L'\0'; // 值太长：看首字符
  return buf[0] != L'\0'; // 存在且非空
}

// 核心压制逻辑：DisableIme（GML 调用）与 WM_TIMER 心跳共用
// v7：彻底不碰键盘布局/输入语言。v6 的 LoadKeyboardLayoutW +
// WM_INPUTLANGCHANGEREQUEST
//     会往系统里加一个英文输入法并一直切过去，污染全局（其它程序中文都用不了），已删除。
//     改成 per-window 断开 IME 上下文（只影响游戏窗口本身）。
// v7.2：再删除 EnumWindows「隐藏候选窗」兜底逻辑——它按类名子串**无条件**匹配，
//     把微信主窗口（类名 WeChatMainWndForPC）当成候选窗每秒
//     SW_HIDE，导致微信被"清掉"。 本函数现在只碰 hwnd
//     这一个游戏窗口，不读也不改任何其它进程/窗口的状态。
static void ApplyImeBlock(HWND hwnd, bool from_timer) {
  if (!hwnd)
    return;
  if (!g_ime_block_active)
    return;

  // 1) 子类化（处理 WM_IME_SETCONTEXT 屏蔽候选窗 + 焦点/心跳）
  if (!GetWindowSubclass(hwnd, ImeWndProc, 1, 0)) {
    SetWindowSubclass(hwnd, ImeWndProc, 1, 0);
  }
  // 2) 断开本窗口的 IME 上下文：不动系统输入法/语言列表
  HIMC prev = ImmAssociateContext(hwnd, nullptr);
  // v7.3：把摘掉的上下文存起来，供输入框获焦时挂回（同一窗口只存首次那个非空值）
  if (prev && g_ime_blocked_hwnd != hwnd) {
    g_ime_saved_himc = prev;
    g_ime_blocked_hwnd = hwnd;
  }
  HIMC now = ImmGetContext(hwnd); // 同线程查询：断开后应为 NULL
  if (now)
    ImmReleaseContext(hwnd, now);
  // 3) 窗口级心跳：不依赖 GML 对象存活
  if (g_ime_timer_hwnd != hwnd) {
    SetTimer(hwnd, kImeTimerId, 1000, nullptr);
    g_ime_timer_hwnd = hwnd;
  }
  // 4) [v7.2 已删除] 这里原本 EnumWindows 隐藏"看起来像候选窗"的其它进程窗口。
  //    该机制对 v7 无任何贡献（生效靠上面的 HIMC 断开，hidden 恒为
  //    0），却会误伤： 微信主窗口类名 WeChatMainWndForPC 命中关键字表 → 被每秒
  //    SW_HIDE → 微信被"清掉"。
  //    现整条移除。本函数只操作游戏自己的窗口，对系统与其它程序零副作用。
  // 5) 日志：默认完全关闭（IME 不写任何行，不占玩家空间）。
  //    说明：latest.log 是游戏原有的 native
  //    错误日志（存档/备份等也写它），文件本身不能删； 这里只保证 IME
  //    相关行默认 0 条，设 FVM_IME_DEBUG=1 才输出（排查用）。
  const bool debug = ImeDebugEnvSet();
  if (debug) {
    static int ticks = 0;
    static int ticks_timer = 0;
    static int ticks_gml = 0;
    ++ticks;
    if (from_timer)
      ++ticks_timer;
    else
      ++ticks_gml;
    static HWND last_hwnd = nullptr;
    static DWORD last_debug_tick = 0;
    const DWORD now_tick = GetTickCount();
    const bool hwnd_changed = (hwnd != last_hwnd);
    const bool himc_reattached = (prev != nullptr);
    const bool debug_due = (now_tick - last_debug_tick >= 5000);
    const bool alive_due = ((ticks % 300) == 0);
    if (hwnd_changed || himc_reattached || debug_due || alive_due) {
      last_hwnd = hwnd;
      last_debug_tick = now_tick;
      HWND fg = GetForegroundWindow();
      wchar_t fg_cls[256] = {0};
      if (fg)
        GetClassNameW(fg, fg_cls, 255);
      char msg[512] = {0};
      sprintf_s(msg, sizeof(msg),
                "DisableIme[v7.3]: src=%s ticks=%d(timer=%d,gml=%d) hwnd=%p "
                "himc_prev=%p himc_now=%p saved=%p hide=off fg=%p fgcls=%s "
                "debug=%d",
                from_timer ? "T" : "G", ticks, ticks_timer, ticks_gml, hwnd,
                reinterpret_cast<void *>(prev), reinterpret_cast<void *>(now),
                reinterpret_cast<void *>(g_ime_saved_himc), fg,
                WideToUtf8(fg_cls).c_str(), 1);
      LogNativeError(0, msg);
    }
    LogImeWindowSnapshot(hwnd, true);
  }
}

/**
 * @brief 屏蔽输入法（IME）候选框。返回 0 表示调用成功。
 *        v7.2：per-window 断开 IME 上下文（ImmAssociateContext(hwnd,nullptr)）
 *             + WM_IME_SETCONTEXT 清候选窗标志 + 焦点重挂 + 窗口级 1 秒心跳 +
 * 诊断日志。
 *             **不触碰键盘布局/输入语言**（v6 会污染系统输入法，已废弃）。
 *             **不枚举、不隐藏任何其它进程的窗口**（v7.1
 * 误伤微信主窗口，已移除）。 只操作 GML
 * 传入的游戏窗口句柄，对系统与其它程序零副作用。
 */
GmlCallable auto DisableIme(double hwnd_value) -> double {
  HWND hwnd = static_cast<HWND>(
      reinterpret_cast<void *>(static_cast<INT_PTR>(hwnd_value)));
  if (!hwnd)
    hwnd = GetForegroundWindow();
  g_ime_block_active = true;
  ApplyImeBlock(hwnd, false);
  return static_cast<double>(NativeError::Ok);
}

static void ApplyImeEnable(HWND hwnd) {
  if (!hwnd)
    return;
  if (GetWindowSubclass(hwnd, ImeWndProc, 1, 0)) {
    RemoveWindowSubclass(hwnd, ImeWndProc, 1);
  }
  KillTimer(hwnd, kImeTimerId);
  if (g_ime_timer_hwnd == hwnd)
    g_ime_timer_hwnd = nullptr;
  if (g_ime_saved_himc) {
    ImmAssociateContext(hwnd, g_ime_saved_himc);
    g_ime_saved_himc = nullptr;
  } else {
    ImmAssociateContextEx(hwnd, nullptr, IACE_DEFAULT);
  }
  g_ime_blocked_hwnd = nullptr;
}

/**
 * @brief 放开输入法（IME）。返回 0 表示调用成功。
 *        v7.3：与 native_disable_ime 成对使用——游戏内输入框获得焦点时放开，
 *              失焦时再调 native_disable_ime 恢复屏蔽。
 */

GmlCallable auto EnableIme(double hwnd_value) -> double {
  HWND hwnd = static_cast<HWND>(
      reinterpret_cast<void *>(static_cast<INT_PTR>(hwnd_value)));
  if (!hwnd)
    hwnd = GetForegroundWindow();
  ApplyImeEnable(hwnd);
  return static_cast<double>(NativeError::Ok);
}

GmlCallable auto UnzipMapFile(const char *zip_path,
                              const char *parent_folder_full_path) -> double {
  if (!zip_path || !*zip_path || !parent_folder_full_path ||
      !*parent_folder_full_path) {
    return FailWith(NativeError::InvalidArgument,
                    "UnzipMapFile: empty zip_path or parent_folder");
  }
  try {
    const std::wstring w_zip = FileSystem::Utf8ToUtf16(zip_path);
    const std::wstring w_out = FileSystem::Utf8ToUtf16(parent_folder_full_path);
    ArchiveExtractor extractor(ArchiveExtractor::FindSevenZipDll());
    extractor.extract(w_zip, w_out);
    return static_cast<double>(NativeError::Ok);
  } catch (const ArchiveException &e) {
    return FailWith(e.code(), e.what());
  } catch (const std::exception &e) {
    return FailWith(NativeError::ExtractFailed, e.what());
  }
}
