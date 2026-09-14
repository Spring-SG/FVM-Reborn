#include "archive_extractor.h"

#include "Common/Common.h"
#include "Common/MyInitGuid.h"
#include "Common/MyCom.h"
#include "7zip/Archive/IArchive.h"
#include "7zip/IPassword.h"
#include "7zip/PropID.h"

#include <windows.h>

#include <algorithm>
#include <cstdint>
#include <fstream>
#include <vector>

namespace {

std::wstring PathToWide(const std::filesystem::path& path) {
  return path.wstring();
}

bool FileExistsW(const std::filesystem::path& path) {
  const DWORD attr = GetFileAttributesW(PathToWide(path).c_str());
  return attr != INVALID_FILE_ATTRIBUTES &&
         (attr & FILE_ATTRIBUTE_DIRECTORY) == 0;
}

std::filesystem::path ModuleDirectory(HMODULE module) {
  wchar_t buf[MAX_PATH] = {};
  const DWORD len = GetModuleFileNameW(module, buf, MAX_PATH);
  if (len == 0 || len >= MAX_PATH) {
    return {};
  }
  return std::filesystem::path(buf).parent_path();
}

HMODULE ThisModule() {
  HMODULE module = nullptr;
  if (!GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS |
                              GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                          reinterpret_cast<LPCWSTR>(&ThisModule), &module)) {
    return nullptr;
  }
  return module;
}

bool IsSafeRelativePath(const std::filesystem::path& relative) {
  if (relative.empty() || relative.is_absolute()) {
    return false;
  }
  const std::wstring text = relative.wstring();
  if (!text.empty() && (text[0] == L'\\' || text[0] == L'/')) {
    return false;
  }
  for (const auto& part : relative) {
    if (part == L"..") {
      return false;
    }
  }
  return true;
}

std::filesystem::path ResolveSafeOutputPath(
    const std::filesystem::path& output_dir,
    const std::wstring& entry_path) {
  std::filesystem::path relative = std::filesystem::path(entry_path).lexically_normal();
  if (!IsSafeRelativePath(relative)) {
    throw ArchiveException(ArchiveErr::PathTraversal,
                           "Archive entry path is not allowed");
  }

  const std::filesystem::path output_normal = output_dir.lexically_normal();
  const std::filesystem::path full = (output_normal / relative).lexically_normal();

  std::wstring prefix = output_normal.wstring();
  if (prefix.empty() ||
      (*prefix.rbegin() != L'\\' && *prefix.rbegin() != L'/')) {
    prefix.push_back(L'\\');
  }
  const std::wstring full_text = full.wstring();
  if (full_text.size() < prefix.size() ||
      _wcsnicmp(full_text.c_str(), prefix.c_str(), prefix.size()) != 0) {
    throw ArchiveException(ArchiveErr::PathTraversal,
                           "Archive entry escaped the output directory");
  }
  return full;
}

class SevenZipLibrary {
 public:
  explicit SevenZipLibrary(const std::filesystem::path& dll_path) {
    module_ = LoadLibraryW(PathToWide(dll_path).c_str());
    if (!module_) {
      throw ArchiveException(ArchiveErr::DllLoadFailed, "Failed to load 7z.dll");
    }
    create_object_ = reinterpret_cast<Func_CreateObject>(
        GetProcAddress(module_, "CreateObject"));
    get_number_of_formats_ = reinterpret_cast<Func_GetNumberOfFormats>(
        GetProcAddress(module_, "GetNumberOfFormats"));
    get_handler_property2_ = reinterpret_cast<Func_GetHandlerProperty2>(
        GetProcAddress(module_, "GetHandlerProperty2"));
    get_is_arc_ = reinterpret_cast<Func_GetIsArc>(
        GetProcAddress(module_, "GetIsArc"));
    if (!create_object_ || !get_number_of_formats_ ||
        !get_handler_property2_) {
      FreeLibrary(module_);
      module_ = nullptr;
      throw ArchiveException(ArchiveErr::DllLoadFailed,
                             "7z.dll is missing required exports");
    }
  }

  ~SevenZipLibrary() {
    if (module_) {
      FreeLibrary(module_);
    }
  }

  SevenZipLibrary(const SevenZipLibrary&) = delete;
  SevenZipLibrary& operator=(const SevenZipLibrary&) = delete;

  Func_CreateObject create_object() const { return create_object_; }
  Func_GetNumberOfFormats get_number_of_formats() const {
    return get_number_of_formats_;
  }
  Func_GetHandlerProperty2 get_handler_property2() const {
    return get_handler_property2_;
  }
  Func_GetIsArc get_is_arc() const { return get_is_arc_; }

 private:
  HMODULE module_ = nullptr;
  Func_CreateObject create_object_ = nullptr;
  Func_GetNumberOfFormats get_number_of_formats_ = nullptr;
  Func_GetHandlerProperty2 get_handler_property2_ = nullptr;
  Func_GetIsArc get_is_arc_ = nullptr;
};

Z7_CLASS_IMP_IInStream(CInFileStreamWin)
  HANDLE handle_ = INVALID_HANDLE_VALUE;

 public:
  CInFileStreamWin() = default;
  ~CInFileStreamWin() { Close(); }

  bool Open(const std::filesystem::path& path) {
    Close();
    handle_ = CreateFileW(PathToWide(path).c_str(), GENERIC_READ,
                          FILE_SHARE_READ, nullptr, OPEN_EXISTING,
                          FILE_ATTRIBUTE_NORMAL, nullptr);
    return handle_ != INVALID_HANDLE_VALUE;
  }

  void Close() {
    if (handle_ != INVALID_HANDLE_VALUE) {
      CloseHandle(handle_);
      handle_ = INVALID_HANDLE_VALUE;
    }
  }
};

Z7_COM7F_IMF(CInFileStreamWin::Read(void* data, UInt32 size, UInt32* processedSize))
{
  if (processedSize) {
    *processedSize = 0;
  }
  if (size == 0) {
    return S_OK;
  }
  DWORD read = 0;
  if (!ReadFile(handle_, data, size, &read, nullptr)) {
    return HRESULT_FROM_WIN32(GetLastError());
  }
  if (processedSize) {
    *processedSize = read;
  }
  return S_OK;
}

Z7_COM7F_IMF(CInFileStreamWin::Seek(Int64 offset, UInt32 seekOrigin, UInt64* newPosition))
{
  LARGE_INTEGER move;
  move.QuadPart = offset;
  LARGE_INTEGER result;
  DWORD method = FILE_BEGIN;
  if (seekOrigin == STREAM_SEEK_CUR) {
    method = FILE_CURRENT;
  } else if (seekOrigin == STREAM_SEEK_END) {
    method = FILE_END;
  } else if (seekOrigin != STREAM_SEEK_SET) {
    return STG_E_INVALIDFUNCTION;
  }
  if (!SetFilePointerEx(handle_, move, &result, method)) {
    return HRESULT_FROM_WIN32(GetLastError());
  }
  if (newPosition) {
    *newPosition = static_cast<UInt64>(result.QuadPart);
  }
  return S_OK;
}

class COutFileStreamWin Z7_final : public ISequentialOutStream,
                                   public CMyUnknownImp {
  Z7_IFACES_IMP_UNK_1(ISequentialOutStream)
  HANDLE handle_ = INVALID_HANDLE_VALUE;

 public:
  COutFileStreamWin() = default;
  ~COutFileStreamWin() { Close(); }

  bool CreateAlways(const std::filesystem::path& path) {
    Close();
    handle_ = CreateFileW(PathToWide(path).c_str(), GENERIC_WRITE, 0, nullptr,
                          CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    return handle_ != INVALID_HANDLE_VALUE;
  }

  void Close() {
    if (handle_ != INVALID_HANDLE_VALUE) {
      CloseHandle(handle_);
      handle_ = INVALID_HANDLE_VALUE;
    }
  }
};

Z7_COM7F_IMF(COutFileStreamWin::Write(const void* data, UInt32 size,
                                      UInt32* processedSize))
{
  if (processedSize) {
    *processedSize = 0;
  }
  if (size == 0) {
    return S_OK;
  }
  DWORD written = 0;
  if (!WriteFile(handle_, data, size, &written, nullptr)) {
    return HRESULT_FROM_WIN32(GetLastError());
  }
  if (written == 0) {
    return E_FAIL;
  }
  if (processedSize) {
    *processedSize = written;
  }
  return S_OK;
}

class CArchiveOpenCallback Z7_final : public IArchiveOpenCallback,
                                      public ICryptoGetTextPassword,
                                      public CMyUnknownImp {
  Z7_IFACES_IMP_UNK_2(IArchiveOpenCallback, ICryptoGetTextPassword)
 public:
  bool password_required = false;
};

Z7_COM7F_IMF(CArchiveOpenCallback::SetTotal(const UInt64*, const UInt64*)) {
  return S_OK;
}

Z7_COM7F_IMF(CArchiveOpenCallback::SetCompleted(const UInt64*, const UInt64*)) {
  return S_OK;
}

Z7_COM7F_IMF(CArchiveOpenCallback::CryptoGetTextPassword(BSTR*)) {
  password_required = true;
  return E_ABORT;
}

class CArchiveExtractCallback Z7_final : public IArchiveExtractCallback,
                                         public ICryptoGetTextPassword,
                                         public CMyUnknownImp {
  Z7_IFACES_IMP_UNK_2(IArchiveExtractCallback, ICryptoGetTextPassword)
  Z7_IFACE_COM7_IMP(IProgress)

  CMyComPtr<IInArchive> archive_;
  std::filesystem::path output_dir_;
  COutFileStreamWin* out_file_spec_ = nullptr;
  CMyComPtr<ISequentialOutStream> out_file_;

 public:
  bool password_required = false;
  int error_code = ArchiveErr::Ok;
  std::string error_message;

  void Init(IInArchive* archive, const std::filesystem::path& output_dir) {
    archive_ = archive;
    output_dir_ = output_dir;
  }

  void SetError(int code, const char* message) {
    if (error_code == ArchiveErr::Ok) {
      error_code = code;
      error_message = message ? message : "";
    }
  }
};

Z7_COM7F_IMF(CArchiveExtractCallback::SetTotal(UInt64)) { return S_OK; }

Z7_COM7F_IMF(CArchiveExtractCallback::SetCompleted(const UInt64*)) {
  return S_OK;
}

static HRESULT GetBoolProp(IInArchive* archive, UInt32 index, PROPID prop_id,
                           bool& value) {
  PROPVARIANT prop;
  PropVariantInit(&prop);
  const HRESULT hr = archive->GetProperty(index, prop_id, &prop);
  if (hr != S_OK) {
    PropVariantClear(&prop);
    return hr;
  }
  if (prop.vt == VT_BOOL) {
    value = prop.boolVal != VARIANT_FALSE;
  } else if (prop.vt == VT_EMPTY) {
    value = false;
  } else {
    PropVariantClear(&prop);
    return E_FAIL;
  }
  PropVariantClear(&prop);
  return S_OK;
}

Z7_COM7F_IMF(CArchiveExtractCallback::GetStream(
    UInt32 index, ISequentialOutStream** outStream, Int32 askExtractMode))
{
  *outStream = nullptr;
  out_file_.Release();
  out_file_spec_ = nullptr;

  if (askExtractMode != NArchive::NExtract::NAskMode::kExtract) {
    return S_OK;
  }

  PROPVARIANT path_prop;
  PropVariantInit(&path_prop);
  RINOK(archive_->GetProperty(index, kpidPath, &path_prop))
  std::wstring entry_path;
  if (path_prop.vt == VT_BSTR && path_prop.bstrVal && path_prop.bstrVal[0]) {
    entry_path = path_prop.bstrVal;
  } else {
    entry_path = L"unnamed_" + std::to_wstring(index);
  }
  PropVariantClear(&path_prop);

  bool is_dir = false;
  RINOK(GetBoolProp(archive_, index, kpidIsDir, is_dir))

  bool is_symlink = false;
  GetBoolProp(archive_, index, kpidSymLink, is_symlink);
  if (is_symlink) {
    return S_OK;
  }

  std::filesystem::path dest;
  try {
    dest = ResolveSafeOutputPath(output_dir_, entry_path);
  } catch (const ArchiveException& e) {
    SetError(e.code(), e.what());
    return E_FAIL;
  }

  std::error_code ec;
  if (is_dir) {
    std::filesystem::create_directories(dest, ec);
    if (ec) {
      SetError(ArchiveErr::FileCreateFailed, "Failed to create directory");
      return E_FAIL;
    }
    return S_OK;
  }

  std::filesystem::create_directories(dest.parent_path(), ec);
  if (ec) {
    SetError(ArchiveErr::FileCreateFailed, "Failed to create parent directory");
    return E_FAIL;
  }

  out_file_spec_ = new COutFileStreamWin();
  CMyComPtr<ISequentialOutStream> stream(out_file_spec_);
  if (!out_file_spec_->CreateAlways(dest)) {
    SetError(ArchiveErr::FileCreateFailed, "Failed to create output file");
    return E_FAIL;
  }
  out_file_ = stream;
  *outStream = stream.Detach();
  return S_OK;
}

Z7_COM7F_IMF(CArchiveExtractCallback::PrepareOperation(Int32)) { return S_OK; }

Z7_COM7F_IMF(CArchiveExtractCallback::SetOperationResult(Int32 opRes))
{
  out_file_.Release();
  out_file_spec_ = nullptr;
  if (opRes == NArchive::NExtract::NOperationResult::kOK) {
    return S_OK;
  }
  if (opRes == NArchive::NExtract::NOperationResult::kWrongPassword) {
    password_required = true;
    SetError(ArchiveErr::PasswordRequired, "Password required");
    return E_FAIL;
  }
  SetError(ArchiveErr::ExtractFailed, "Extract operation failed");
  return E_FAIL;
}

Z7_COM7F_IMF(CArchiveExtractCallback::CryptoGetTextPassword(BSTR*))
{
  password_required = true;
  SetError(ArchiveErr::PasswordRequired, "Password required");
  return E_ABORT;
}

bool ReadFilePrefix(const std::filesystem::path& path, std::vector<Byte>& buf) {
  std::ifstream ifs(path, std::ios::binary);
  if (!ifs) {
    return false;
  }
  buf.resize(1 << 15);
  ifs.read(reinterpret_cast<char*>(buf.data()),
           static_cast<std::streamsize>(buf.size()));
  buf.resize(static_cast<size_t>(ifs.gcount()));
  return !buf.empty();
}

bool TryGetFormatClassId(Func_GetHandlerProperty2 get_prop, UInt32 index,
                         GUID& clsid) {
  PROPVARIANT prop;
  PropVariantInit(&prop);
  if (get_prop(index, NArchive::NHandlerPropID::kClassID, &prop) != S_OK) {
    PropVariantClear(&prop);
    return false;
  }
  bool ok = false;
  if (prop.vt == VT_BSTR && prop.bstrVal != nullptr) {
    memcpy(&clsid, prop.bstrVal, sizeof(GUID));
    ok = true;
  }
  PropVariantClear(&prop);
  return ok;
}

bool FormatLooksLikeArchive(Func_GetIsArc get_is_arc, UInt32 index,
                            const std::vector<Byte>& prefix) {
  if (!get_is_arc || prefix.empty()) {
    return true;
  }
  Func_IsArc is_arc = nullptr;
  if (get_is_arc(index, &is_arc) != S_OK || !is_arc) {
    return true;
  }
  const UInt32 result = is_arc(prefix.data(), prefix.size());
  return result == k_IsArc_Res_YES || result == k_IsArc_Res_NEED_MORE;
}

CMyComPtr<IInArchive> OpenArchive(const SevenZipLibrary& lib,
                                 IInStream* stream,
                                 CArchiveOpenCallback* open_callback,
                                 const std::vector<Byte>& prefix) {
  UInt32 num_formats = 0;
  if (lib.get_number_of_formats()(&num_formats) != S_OK || num_formats == 0) {
    throw ArchiveException(ArchiveErr::UnsupportedFormat,
                           "7z.dll reported no archive formats");
  }

  for (UInt32 i = 0; i < num_formats; ++i) {
    if (!FormatLooksLikeArchive(lib.get_is_arc(), i, prefix)) {
      continue;
    }
    GUID clsid{};
    if (!TryGetFormatClassId(lib.get_handler_property2(), i, clsid)) {
      continue;
    }
    CMyComPtr<IInArchive> archive;
    if (lib.create_object()(&clsid, &IID_IInArchive,
                            reinterpret_cast<void**>(&archive)) != S_OK ||
        !archive) {
      continue;
    }
    UInt64 max_check = 1ull << 22;
    stream->Seek(0, STREAM_SEEK_SET, nullptr);
    const HRESULT hr = archive->Open(stream, &max_check, open_callback);
    if (hr == S_OK) {
      return archive;
    }
    archive->Close();
  }
  return {};
}

}  // namespace

ArchiveExtractor::ArchiveExtractor(std::filesystem::path seven_zip_dll)
    : dll_path_(std::move(seven_zip_dll)) {}

auto ArchiveExtractor::FindSevenZipDll() -> std::filesystem::path {
  std::vector<std::filesystem::path> candidates;
  if (const HMODULE self = ThisModule()) {
    const auto dir = ModuleDirectory(self);
    candidates.push_back(dir / "7z.dll");
    candidates.push_back(dir / "native" / "7z.dll");
  }
  const auto exe_dir = ModuleDirectory(nullptr);
  candidates.push_back(exe_dir / "7z.dll");
  candidates.push_back(exe_dir / "native" / "7z.dll");
  wchar_t cwd[MAX_PATH] = {};
  if (GetCurrentDirectoryW(MAX_PATH, cwd) > 0) {
    const std::filesystem::path current(cwd);
    candidates.push_back(current / "7z.dll");
    candidates.push_back(current / "native" / "7z.dll");
  }

  for (const auto& candidate : candidates) {
    if (FileExistsW(candidate)) {
      return candidate;
    }
  }
  throw ArchiveException(ArchiveErr::DllLoadFailed, "7z.dll was not found");
}

void ArchiveExtractor::extract(const std::filesystem::path& archive,
                               const std::filesystem::path& output_directory) {
  if (archive.empty() || output_directory.empty()) {
    throw ArchiveException(ArchiveErr::InvalidArchive, "Empty archive or output path");
  }
  if (!FileExistsW(archive)) {
    throw ArchiveException(ArchiveErr::InvalidArchive, "Archive file does not exist");
  }

  std::error_code ec;
  std::filesystem::create_directories(output_directory, ec);
  if (ec) {
    throw ArchiveException(ArchiveErr::FileCreateFailed,
                           "Failed to create output directory");
  }

  SevenZipLibrary lib(dll_path_);

  CInFileStreamWin* in_spec = new CInFileStreamWin();
  CMyComPtr<IInStream> in_stream(in_spec);
  if (!in_spec->Open(archive)) {
    throw ArchiveException(ArchiveErr::OpenFailed, "Failed to open archive file");
  }

  std::vector<Byte> prefix;
  ReadFilePrefix(archive, prefix);

  CArchiveOpenCallback* open_spec = new CArchiveOpenCallback();
  CMyComPtr<IArchiveOpenCallback> open_callback(open_spec);

  CMyComPtr<IInArchive> in_archive =
      OpenArchive(lib, in_stream, open_spec, prefix);
  if (!in_archive) {
    if (open_spec->password_required) {
      throw ArchiveException(ArchiveErr::PasswordRequired,
                             "Password required");
    }
    throw ArchiveException(ArchiveErr::UnsupportedFormat,
                           "Unsupported or invalid archive");
  }

  CArchiveExtractCallback* extract_spec = new CArchiveExtractCallback();
  CMyComPtr<IArchiveExtractCallback> extract_callback(extract_spec);
  extract_spec->Init(in_archive, output_directory);

  const HRESULT hr =
      in_archive->Extract(nullptr, static_cast<UInt32>(-1), 0, extract_spec);
  in_archive->Close();

  if (extract_spec->password_required || open_spec->password_required) {
    throw ArchiveException(ArchiveErr::PasswordRequired, "Password required");
  }
  if (extract_spec->error_code != ArchiveErr::Ok) {
    throw ArchiveException(extract_spec->error_code, extract_spec->error_message);
  }
  if (hr != S_OK) {
    throw ArchiveException(ArchiveErr::ExtractFailed, "Extract failed");
  }
}
