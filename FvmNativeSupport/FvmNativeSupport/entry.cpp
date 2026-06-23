
#include "FileSystem.h"
#include "Typedef.h"

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
GmlCallable auto CopyFolder(const char* source, const char* destination) -> double {
    return FileSystem::CopyAndMergeDirectory(source, destination) ? 1.0 : 0.0;
}

/**
 * @brief 删除指定文件夹及其内容 (1为成功, 0为失败)
 */
GmlCallable auto DeleteFolder(const char* path) -> double {
    return FileSystem::DeleteFolder(path) ? 1.0 : 0.0;
}