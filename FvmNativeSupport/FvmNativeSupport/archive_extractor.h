#pragma once

#include <filesystem>
#include <stdexcept>
#include <string>

namespace ArchiveErr {
constexpr int Ok = 0;
constexpr int DllLoadFailed = -10;
constexpr int InvalidArchive = -11;
constexpr int ExtractFailed = -12;
constexpr int PathTraversal = -13;
constexpr int PasswordRequired = -14;
constexpr int UnsupportedFormat = -15;
constexpr int OpenFailed = -16;
constexpr int FileCreateFailed = -17;
}  // namespace ArchiveErr

class ArchiveException : public std::runtime_error {
 public:
  ArchiveException(int code, const std::string& message)
      : std::runtime_error(message), code_(code) {}

  int code() const { return code_; }

 private:
  int code_;
};

class ArchiveExtractor {
 public:
  explicit ArchiveExtractor(std::filesystem::path seven_zip_dll);

  void extract(const std::filesystem::path& archive,
               const std::filesystem::path& output_directory);

  static auto FindSevenZipDll() -> std::filesystem::path;

 private:
  std::filesystem::path dll_path_;
};
