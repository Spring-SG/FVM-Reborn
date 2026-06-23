#pragma once
#include <windows.h>
#include <shellapi.h>
#include <string>
#include <filesystem>
#include <vector>

class FileSystem {
public:
    static auto OpenFolder(std::string path) -> double {
        std::wstring w_path = Utf8ToUtf16(path.c_str());
        auto ret = ShellExecuteW(NULL, L"open", w_path.c_str(), NULL, NULL, SW_SHOWDEFAULT);
        return static_cast<double>(reinterpret_cast<INT_PTR>(ret) > 32);
    }

    static auto FolderExists(std::string path) -> bool {
        std::wstring w_path = Utf8ToUtf16(path.c_str());
        DWORD dwAttrib = GetFileAttributesW(w_path.c_str());
        return (dwAttrib != INVALID_FILE_ATTRIBUTES && (dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
    }

    static auto FileExists(std::string path) -> bool {
        std::wstring w_path = Utf8ToUtf16(path.c_str());
        DWORD dwAttrib = GetFileAttributesW(w_path.c_str());
        return (dwAttrib != INVALID_FILE_ATTRIBUTES && !(dwAttrib & FILE_ATTRIBUTE_DIRECTORY));
    }

    static auto CopyAndMergeDirectory(const char* source, const char* targetParent) -> bool {
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

        SHFILEOPSTRUCTW fileOp = { 0 };
        fileOp.hwnd = NULL;
        fileOp.wFunc = FO_DELETE;         
        fileOp.pFrom = w_path.c_str();     
        fileOp.pTo = NULL;                

        fileOp.fFlags = FOF_NOCONFIRMATION | FOF_SILENT;

        int result = SHFileOperationW(&fileOp);

        return result == 0;
    }
private:
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
};