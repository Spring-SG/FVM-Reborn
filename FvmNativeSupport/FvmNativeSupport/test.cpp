
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <string>

#include "entry.h"

// ── helpers ─────────────────────────────────────────────────

static auto CheckDirHasSameContent(const std::string& dir1,
                                   const std::string& dir2) -> bool {
  namespace fs = std::filesystem;
  std::error_code ec;
  if (!fs::exists(dir1, ec) || !fs::exists(dir2, ec)) {
    return false;
  }
  for (const auto& entry : fs::recursive_directory_iterator(dir1, ec)) {
    if (entry.is_regular_file()) {
      fs::path relative_path = fs::relative(entry.path(), dir1, ec);
      fs::path corresponding_path = fs::path(dir2) / relative_path;
      if (!fs::exists(corresponding_path, ec) ||
          !fs::is_regular_file(corresponding_path, ec)) {
        return false;
      }
      std::ifstream file1(entry.path(), std::ios::binary);
      std::ifstream file2(corresponding_path, std::ios::binary);
      if (!file1.is_open() || !file2.is_open()) {
        return false;
      }
      std::istreambuf_iterator<char> begin1(file1), end1;
      std::istreambuf_iterator<char> begin2(file2), end2;
      if (!std::equal(begin1, end1, begin2)) {
        return false;
      }
    }
  }
  return true;
}

static auto CreateTestFile(const std::filesystem::path& path,
                           const std::string& content) -> bool {
  std::ofstream ofs(path);
  if (!ofs.is_open()) return false;
  ofs << content;
  return true;
}

// ── test helpers ────────────────────────────────────────────

static auto TestStartBackupWithTargetFile(
    const std::filesystem::path& saves_dir,
    const std::filesystem::path& backup_file, const char* label,
    double expected) -> bool {
  double result = StartBackupWithTargetFile(saves_dir.string().c_str(),
                                            backup_file.string().c_str());
  if (result != expected) {
    printf("  FAIL [%s]: expected %f, got %f\n", label, expected, result);
    return false;
  }
  bool file_exists = std::filesystem::exists(backup_file);
  if (expected == 1.0 && !file_exists) {
    printf("  FAIL [%s]: backup file was not created\n", label);
    return false;
  }
  return true;
}

static auto TestRestoreBackupWithTargetFile(
    const std::filesystem::path& restore_dir,
    const std::filesystem::path& backup_file, const char* label,
    double expected) -> bool {
  double result = RestoreBackupWithTargetFile(restore_dir.string().c_str(),
                                              backup_file.string().c_str());
  if (result != expected) {
    printf("  FAIL [%s]: expected %f, got %f\n", label, expected, result);
    return false;
  }
  return true;
}

// ── tests ───────────────────────────────────────────────────

static int RunAllTests() {
  namespace fs = std::filesystem;

  fs::path test_root = fs::temp_directory_path() / "FvmNativeSupport_test";
  fs::path saves_dir = test_root / "saves";
  fs::path backup_file = test_root / "backup.json";
  fs::path restore_dir = test_root / "restore";

  fs::remove_all(test_root);

  // prepare test data
  fs::create_directories(saves_dir);
  CreateTestFile(saves_dir / "save1.json", R"({"level":1,"hp":100})");
  CreateTestFile(saves_dir / "save2.json", R"({"level":2,"hp":80})");
  CreateTestFile(saves_dir / "readme.txt", "this should be ignored");

  // ── 1. backup ──────────────────────────────────────────
  printf("[Test 1] StartBackupWithTargetFile - normal backup\n");
  if (!TestStartBackupWithTargetFile(saves_dir, backup_file, "normal backup",
                                     1.0))
    return -1;
  if (!fs::exists(backup_file)) {
    printf("  FAIL: backup file not created\n");
    return -1;
  }
  printf("  PASS\n");

  // ── 2. verify non-json files excluded ──────────────────
  printf("[Test 2] verify only .json files were backed up\n");
  {
    std::ifstream ifs(backup_file);
    std::stringstream buf;
    buf << ifs.rdbuf();
    std::string content = buf.str();
    if (content.find("save1") == std::string::npos ||
        content.find("save2") == std::string::npos) {
      printf("  FAIL: save1 or save2 missing from backup\n");
      return -1;
    }
    if (content.find("readme") != std::string::npos) {
      printf("  FAIL: readme.txt should not be in backup\n");
      return -1;
    }
  }
  printf("  PASS\n");

  // ── 3. restore ────────────────────────────────────────
  printf("[Test 3] RestoreBackupWithTargetFile - normal restore\n");
  fs::create_directories(restore_dir);
  if (!TestRestoreBackupWithTargetFile(restore_dir, backup_file,
                                       "normal restore", 1.0))
    return -1;
  	if (!CheckDirHasSameContent(restore_dir.string(), saves_dir.string())) {
  		printf("  FAIL: restored content does not match source\n");
  		return -1;
  	}
  printf("  PASS\n");

  // ── 4. error handling ─────────────────────────────────
  printf("[Test 4] error handling - null / empty args\n");
  {
    fs::path dummy = test_root / "dummy.json";

    if (!TestStartBackupWithTargetFile("", dummy, "empty saves_dir", 0.0))
      return -1;
    if (!TestStartBackupWithTargetFile("savedir", "", "empty target_file", 0.0))
      return -1;
    if (!TestStartBackupWithTargetFile("savedir", dummy, "nonexistent dir",
                                       0.0))
      return -1;

    if (!TestRestoreBackupWithTargetFile("", dummy, "empty restore dir", 0.0))
      return -1;
    fs::path nonexistent = test_root / "no_such_file.json";
    if (!TestRestoreBackupWithTargetFile(restore_dir, nonexistent,
                                         "nonexistent file", 0.0))
      return -1;
  }
  printf("  PASS\n");

  // ── 5. empty saves dir (no .json files) ────────────────
  printf("[Test 5] empty saves dir\n");
  {
    fs::path empty_saves = test_root / "empty_saves";
    fs::path empty_bak = test_root / "empty_bak.json";
    fs::create_directories(empty_saves);
    if (!TestStartBackupWithTargetFile(empty_saves, empty_bak,
                                       "empty dir backup", 1.0))
      return -1;

    fs::path empty_restore = test_root / "empty_restore";
    fs::create_directories(empty_restore);
    if (!TestRestoreBackupWithTargetFile(empty_restore, empty_bak,
                                         "empty backup restore", 1.0))
      return -1;
  }
  printf("  PASS\n");

  // cleanup
  fs::remove_all(test_root);

  printf("\nall automated tests passed!\n");
  return 0;
}

int main() {
  printf("=== FvmNativeSupport *WithTargetFile tests ===\n\n");

  int result = RunAllTests();
  if (result != 0) {
    printf("\n*** TESTS FAILED ***\n");
  } else {
    printf("\n*** ALL TESTS PASSED ***\n");
  }
  system("pause");

  return 0;
}
