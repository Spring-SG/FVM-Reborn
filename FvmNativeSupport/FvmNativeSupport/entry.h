#pragma once

#include <fstream>
#include <sstream>
#include <string>

#include "file_system.h"
#include "json.hpp"
#include "typedef.h"

using json = nlohmann::json;

/**
 * @brief 打开文件夹
 */
GmlCallable auto OpenFolder(const char* path) -> double {
  return FileSystem::OpenFolder(path);
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
 * @brief 复制并合并文件夹 (1为成功, 0为失败)
 */
GmlCallable auto CopyFolder(const char* source, const char* destination)
    -> double {
  return FileSystem::CopyAndMergeDirectory(source, destination) ? 1.0 : 0.0;
}

/**
 * @brief 删除指定文件夹及其内容 (1为成功, 0为失败)
 */
GmlCallable auto DeleteFolder(const char* path) -> double {
  return FileSystem::DeleteFolder(path) ? 1.0 : 0.0;
}

GmlCallable auto StartBackupWithTargetFile(const char* saves_dir,
                                           const char* target_file) -> double {
  if (!saves_dir || !*saves_dir || !target_file || !*target_file) {
    return 0.0;
  }

  namespace fs = std::filesystem;
  std::wstring w_saves_dir = FileSystem::Utf8ToUtf16(saves_dir);

  if (!fs::exists(w_saves_dir)) {
    return 0.0;
  }

  json backup_json;
  backup_json["files"] = json::array();

  std::error_code ec;
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
    return 0.0;
  }

  std::string json_str = backup_json.dump(4);
  std::vector<uint8_t> data(json_str.begin(), json_str.end());

  return FileSystem::WriteNativeFile(target_file, data) ? 1.0 : 0.0;
}

GmlCallable auto StartBackup(const char* saves_dir) -> double {
  if (!saves_dir || !*saves_dir) {
    return 0.0;
  }

  std::string chosen_folder = FileSystem::ChooseFolder();
  if (chosen_folder.empty()) {
    return 0.0;
  }

  namespace fs = std::filesystem;
  std::wstring w_chosen = FileSystem::Utf8ToUtf16(chosen_folder.c_str());
  fs::path backup_path = fs::path(w_chosen) / L"backup.json";
  std::string backup_path_str = backup_path.string();

  return StartBackupWithTargetFile(saves_dir, backup_path_str.c_str());
}

GmlCallable auto RestoreBackupWithTargetFile(const char* saves_dir,
                                             const char* target_file)
    -> double {
  if (!saves_dir || !*saves_dir || !target_file || !*target_file) {
    return 0.0;
  }

  std::ifstream ifs(FileSystem::Utf8ToUtf16(target_file));
  if (!ifs.is_open()) {
    return 0.0;
  }
  std::stringstream buffer;
  buffer << ifs.rdbuf();
  ifs.close();

  json backup_json;
  try {
    backup_json = json::parse(buffer.str());
  } catch (...) {
    return 0.0;
  }

  namespace fs = std::filesystem;
  std::wstring w_saves_dir = FileSystem::Utf8ToUtf16(saves_dir);
  std::error_code ec;
  fs::create_directories(w_saves_dir, ec);

  for (const auto& file_entry : backup_json["files"]) {
    std::string name = file_entry["name"];
    std::string content = file_entry["content"];

    fs::path file_path =
        fs::path(w_saves_dir) / FileSystem::Utf8ToUtf16(name.c_str());

    std::vector<uint8_t> data(content.begin(), content.end());
    if (!FileSystem::WriteNativeFile(file_path.string(), data)) {
      return 0.0;
    }
  }

  return 1.0;
}

GmlCallable auto RestoreBackup(const char* saves_dir,
                               const char* default_backup_dir) -> double {
  std::string chosen_file = FileSystem::ChooseFileToOpen(default_backup_dir);
  if (chosen_file.empty()) {
    return 0.0;
  }

  return RestoreBackupWithTargetFile(saves_dir, chosen_file.c_str());
}
