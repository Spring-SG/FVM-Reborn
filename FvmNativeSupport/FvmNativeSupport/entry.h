#pragma once
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#ifndef NOMINMAX
#define NOMINMAX
#endif

#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>

#include "file_system.h"
#include "json.hpp"
#include "typedef.h"

#include <imm.h>
#pragma comment(lib, "imm32.lib")

using json = nlohmann::json;

inline void LogNativeError(int error_code, const char* message) {
  const auto& path = NativeLogFilePath();
  if (path.empty()) {
    return;
  }

  std::ofstream ofs(std::filesystem::path(FileSystem::Utf8ToUtf16(path.c_str())),
                    std::ios::app);
  if (!ofs.is_open()) {
    return;
  }

  ofs << "[error_code=" << error_code << "] "
      << (message ? message : "") << '\n';
}

inline auto FailWith(int error_code, const char* message) -> double {
  LogNativeError(error_code, message);
  return static_cast<double>(error_code);
}

/**
 * @brief 设置 native 错误日志文件路径。成功返回 0。
 */
GmlCallable auto SetNativeLogFilePath(const char* log_file_path) -> double {
  if (!log_file_path || !*log_file_path) {
    return FailWith(NativeError::InvalidArgument,
                    "SetNativeLogFilePath: empty log_file_path");
  }
  NativeLogFilePath() = log_file_path;
  return static_cast<double>(NativeError::Ok);
}

/**
 * @brief 打开文件夹。成功返回 0，失败返回 ShellExecute 错误码。
 */
GmlCallable auto OpenFolder(const char* path) -> double {
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
GmlCallable auto FolderExists(const char* path) -> double {
  return FileSystem::FolderExists(path) ? 1.0 : 0.0;
}

/**
 * @brief 检查文件是否存在 (1为真, 0为假)
 */
GmlCallable auto FileExists(const char* path) -> double {
  return FileSystem::FileExists(path) ? 1.0 : 0.0;
}

/**
 * @brief 复制并合并文件夹。成功返回 0，失败返回平台错误码。
 */
GmlCallable auto CopyFolder(const char* source, const char* destination)
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
GmlCallable auto DeleteFolder(const char* path) -> double {
  if (!path || !*path) {
    return FailWith(NativeError::InvalidArgument, "DeleteFolder: empty path");
  }
  int code = FileSystem::DeleteFolder(path);
  if (code != 0) {
    return FailWith(code, "DeleteFolder failed");
  }
  return static_cast<double>(NativeError::Ok);
}

GmlCallable auto StartBackupWithTargetFile(const char* saves_dir,
                                           const char* target_file) -> double {
  if (!saves_dir || !*saves_dir || !target_file || !*target_file) {
    return FailWith(NativeError::InvalidArgument,
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

  for (const auto& entry : fs::directory_iterator(w_saves_dir, ec)) {
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

GmlCallable auto StartBackup(const char* saves_dir) -> double {
  if (!saves_dir || !*saves_dir) {
    return FailWith(NativeError::InvalidArgument, "StartBackup: empty saves_dir");
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

GmlCallable auto RestoreBackupWithTargetFile(const char* saves_dir,
                                             const char* target_file)
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

  for (const auto& file_entry : backup_json["files"]) {
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

GmlCallable auto RestoreBackup(const char* saves_dir,
                               const char* default_backup_dir) -> double {
  std::string saves_dir_copy = (saves_dir && *saves_dir) ? saves_dir : "";
  std::string default_dir_copy =
      (default_backup_dir && *default_backup_dir) ? default_backup_dir : "";

  if (saves_dir_copy.empty()) {
    return FailWith(NativeError::InvalidArgument,
                    "RestoreBackup: empty saves_dir");
  }

  std::string chosen_file =
      FileSystem::ChooseFileToOpen(default_dir_copy.empty()
                                       ? nullptr
                                       : default_dir_copy.c_str());
  if (chosen_file.empty()) {
    return FailWith(NativeError::OperationCancelled,
                    "RestoreBackup: file dialog cancelled");
  }

  return RestoreBackupWithTargetFile(saves_dir_copy.c_str(),
                                     chosen_file.c_str());
}

/**
 * @brief 屏蔽当前线程的输入法（IME），让中文候选框不再弹出。
 *        返回 0 表示成功（或已达到屏蔽效果）。
 */
GmlCallable auto DisableIme() -> double {
  // 1) 禁用当前线程 IME（游戏主线程，候选框不弹）
  ImmDisableIME(GetCurrentThreadId());

  // 2) 兜底：把前台窗口的 IME 上下文置空（更彻底）
  HWND hwnd = GetForegroundWindow();
  if (hwnd) {
    HIMC himc = ImmGetContext(hwnd);
    if (himc) {
      ImmAssociateContext(hwnd, nullptr);
      ImmReleaseContext(hwnd, himc);
    }
  }

  return static_cast<double>(NativeError::Ok);
}
