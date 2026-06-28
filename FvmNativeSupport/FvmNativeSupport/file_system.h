#pragma once
#include <windows.h>
//
#include <Commdlg.h>
#include <ShlObj_core.h>
#include <shellapi.h>

#include <filesystem>
#include <map>
#include <string>
#include <vector>

using FileBufferID = std::uint8_t;

class FileSystem {
 public:
  static auto GetInstance() -> FileSystem& {
    static FileSystem instance;
    return instance;
  }

  static auto OpenFolder(std::string path) -> double {
    std::wstring w_path = Utf8ToUtf16(path.c_str());
    auto ret = ShellExecuteW(NULL, L"open", w_path.c_str(), NULL, NULL,
                             SW_SHOWDEFAULT);
    return static_cast<double>(reinterpret_cast<INT_PTR>(ret) > 32);
  }

  static auto FolderExists(std::string path) -> bool {
    std::wstring w_path = Utf8ToUtf16(path.c_str());
    DWORD dwAttrib = GetFileAttributesW(w_path.c_str());
    return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
            (dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
  }

  static auto FileExists(std::string path) -> bool {
    std::wstring w_path = Utf8ToUtf16(path.c_str());
    DWORD dwAttrib = GetFileAttributesW(w_path.c_str());
    return (dwAttrib != INVALID_FILE_ATTRIBUTES &&
            !(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
  }

  static auto CopyAndMergeDirectory(const char* source,
                                    const char* targetParent) -> bool {
    namespace fs = std::filesystem;

    std::wstring w_src_str = Utf8ToUtf16(source);
    std::wstring w_dst_parent_str = Utf8ToUtf16(targetParent);

    fs::path srcPath(w_src_str);
    fs::path dstParentPath(w_dst_parent_str);

    fs::path finalDstPath = dstParentPath / srcPath.filename();

    std::error_code ec;
    if (!fs::exists(srcPath, ec)) return false;

    if (!fs::exists(dstParentPath, ec)) {
      fs::create_directories(dstParentPath, ec);
    }

    fs::copy(srcPath, finalDstPath,
             fs::copy_options::recursive | fs::copy_options::overwrite_existing,
             ec);

    return !ec;
  }

  static auto DeleteFolder(std::string path) -> bool {
    std::wstring w_path = Utf8ToUtf16(path.c_str());

    w_path.push_back(L'\0');

    SHFILEOPSTRUCTW fileOp = {0};
    fileOp.hwnd = NULL;
    fileOp.wFunc = FO_DELETE;
    fileOp.pFrom = w_path.c_str();
    fileOp.pTo = NULL;

    fileOp.fFlags = FOF_NOCONFIRMATION | FOF_SILENT;

    int result = SHFileOperationW(&fileOp);

    return result == 0;
  }

  static auto ChooseFileToOpen(const char* default_dir = nullptr)
      -> std::string {
    OPENFILENAMEW ofn = {0};
    ofn.lStructSize = sizeof(ofn);
    ofn.lpstrFilter = L"JSON Files (*.json)\0*.json\0All Files (*.*)\0*.*\0";
    ofn.nFilterIndex = 1;
    ofn.lpstrFile = new wchar_t[MAX_PATH]();
    ofn.nMaxFile = MAX_PATH;
    ofn.lpstrTitle = L"Select a backup file";
    ofn.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | OFN_PATHMUSTEXIST;

    std::wstring w_default_dir;
    if (default_dir && *default_dir) {
      w_default_dir = Utf8ToUtf16(default_dir);
      ofn.lpstrInitialDir = w_default_dir.c_str();
    }

    std::string result;
    if (GetOpenFileNameW(&ofn)) {
      int size_needed = WideCharToMultiByte(CP_UTF8, 0, ofn.lpstrFile, -1, NULL,
                                            0, NULL, NULL);
      if (size_needed > 0) {
        result.resize(size_needed);
        WideCharToMultiByte(CP_UTF8, 0, ofn.lpstrFile, -1, &result[0],
                            size_needed, NULL, NULL);
        if (!result.empty() && result.back() == '\0') {
          result.pop_back();
        }
      }
    }
    delete[] ofn.lpstrFile;
    return result;
  }

  static auto ChooseFolder() -> std::string {
    BROWSEINFOW bi = {0};
    bi.lpszTitle = L"Select a folder";
    bi.ulFlags = BIF_RETURNONLYFSDIRS | BIF_NEWDIALOGSTYLE;
    LPITEMIDLIST pidl = SHBrowseForFolderW(&bi);
    if (pidl == NULL) {
      return "";
    }
    wchar_t path[MAX_PATH];
    if (!SHGetPathFromIDListW(pidl, path)) {
      CoTaskMemFree(pidl);
      return "";
    }
    CoTaskMemFree(pidl);
    int size_needed =
        WideCharToMultiByte(CP_UTF8, 0, path, -1, NULL, 0, NULL, NULL);
    if (size_needed <= 0) return "";
    std::string utf8_str(size_needed, 0);
    WideCharToMultiByte(CP_UTF8, 0, path, -1, &utf8_str[0], size_needed, NULL,
                        NULL);
    if (!utf8_str.empty() && utf8_str.back() == '\0') {
      utf8_str.pop_back();
    }
    return utf8_str;
  }

  auto ReadNativeFile(const std::string& path) -> FileBufferID {
    std::wstring w_path = Utf8ToUtf16(path.c_str());

    if (file_buffer_id_map_.find(path) != file_buffer_id_map_.end()) {
      return file_buffer_id_map_[path];
    }

    HANDLE file_handler =
        CreateFileW(w_path.c_str(), GENERIC_READ, FILE_SHARE_READ, NULL,
                    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
    if (file_handler == INVALID_HANDLE_VALUE) {
      return 0;
    }
    DWORD file_size = GetFileSize(file_handler, NULL);
    std::vector<uint8_t> data(file_size);
    DWORD bytes_read = 0;
    BOOL read_result =
        ReadFile(file_handler, data.data(), file_size, &bytes_read, NULL);
    CloseHandle(file_handler);
    if (!read_result || bytes_read != file_size) {
      return 0;
    }

    FileBufferID new_id = file_buffer_id_counter_.fetch_add(1);
    file_buffer_data_map_[new_id] = std::move(data);
    file_buffer_id_map_[path] = new_id;
    file_buffer_path_map_[new_id] = path;

    return new_id;
  }

  auto GetNativeFileSize(FileBufferID id) -> uint64_t {
    if (file_buffer_data_map_.find(id) == file_buffer_data_map_.end()) {
      return 0;
    }
    auto& data = file_buffer_data_map_[id];
    return static_cast<uint64_t>(data.size());
  }

  auto GetNativeFileData(FileBufferID id) -> const std::vector<uint8_t>& {
    static const std::vector<uint8_t> empty;

    auto it = file_buffer_data_map_.find(id);

    if (it == file_buffer_data_map_.end()) {
      return empty;
    }

    return it->second;
  }

  auto ReleaseNativeFile(FileBufferID id) -> bool {
    if (file_buffer_data_map_.find(id) == file_buffer_data_map_.end()) {
      return false;
    }
    if (file_buffer_path_map_.find(id) != file_buffer_path_map_.end()) {
      std::string path = file_buffer_path_map_[id];
      file_buffer_id_map_.erase(path);
    }
    file_buffer_data_map_.erase(id);
    file_buffer_path_map_.erase(id);
    return true;
  }

  static auto WriteNativeFile(const std::string& path,
                              const std::vector<uint8_t>& data) -> bool {
    std::wstring w_path = Utf8ToUtf16(path.c_str());
    HANDLE file_handler =
        CreateFileW(w_path.c_str(), GENERIC_WRITE, 0, NULL, CREATE_ALWAYS,
                    FILE_ATTRIBUTE_NORMAL, NULL);
    if (file_handler == INVALID_HANDLE_VALUE) {
      return false;
    }
    DWORD bytes_written = 0;
    BOOL write_result =
        WriteFile(file_handler, data.data(), static_cast<DWORD>(data.size()),
                  &bytes_written, NULL);
    CloseHandle(file_handler);
    return write_result && bytes_written == data.size();
  }

 public:
  static auto Utf8ToUtf16(const char* utf8_str) -> std::wstring {
    if (!utf8_str) return L"";

    int size_needed = MultiByteToWideChar(CP_UTF8, 0, utf8_str, -1, NULL, 0);
    if (size_needed <= 0) return L"";

    std::wstring utf16_str(size_needed, 0);
    MultiByteToWideChar(CP_UTF8, 0, utf8_str, -1, &utf16_str[0], size_needed);

    if (!utf16_str.empty() && utf16_str.back() == L'\0') {
      utf16_str.pop_back();
    }

    return utf16_str;
  }

 private:
  FileSystem() = default;

  std::atomic_uint8_t file_buffer_id_counter_{1};
  std::map<std::string, FileBufferID> file_buffer_id_map_;
  std::map<FileBufferID, std::string> file_buffer_path_map_;
  std::map<FileBufferID, std::vector<uint8_t>> file_buffer_data_map_;
};