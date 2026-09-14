#pragma once

#include <string>

#define GmlCallable extern "C" __declspec(dllexport)

// 自定义错误码使用负数，避免与 Win32 / ShellExecute / SHFileOperation
// 等平台正数错误码冲突。
namespace NativeError {
constexpr int Ok = 0;
constexpr int InvalidArgument = -1;
constexpr int JsonParseFailed = -2;
constexpr int OperationCancelled = -3;
constexpr int EncodingFailed = -4;
constexpr int UnknownFailure = -5;
constexpr int DllLoadFailed = -10;
constexpr int InvalidArchive = -11;
constexpr int ExtractFailed = -12;
constexpr int PathTraversal = -13;
constexpr int PasswordRequired = -14;
constexpr int UnsupportedFormat = -15;
constexpr int OpenFailed = -16;
constexpr int FileCreateFailed = -17;
}  // namespace NativeError

inline auto NativeLogFilePath() -> std::string& {
  static std::string path;
  return path;
}
