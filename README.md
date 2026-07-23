# 美食大战老鼠：重生

《美食大战老鼠：重生》是一款基于 GameMaker 引擎重新编写的《美食大战老鼠》同人游戏，旨在回归塔防初衷，优化不合理的游戏体验。

---

## 📋 目录

- [软件简介](#软件简介)
- [安装与运行](#安装与运行)
- [构建方式](#构建方式)
- [分支说明](#分支说明)
- [贡献指南](#贡献指南)
- [问题反馈](#问题反馈)
- [权限声明](#权限声明)
- [免责声明](#免责声明)

---

## 软件简介

《美食大战老鼠：重生》是使用 GameMaker 引擎重新编写的美食大战老鼠同人游戏，旨在回归塔防初衷，优化不合理的游戏体验。

## 分支说明

本仓库包含以下主要分支：

- **master(gitee)/main(github)**：稳定版分支，用于发布经过测试的稳定版本。建议通过此分支开发修改版。
- **develop**：开发版分支，用于进行日常开发和功能迭代。

## 权限声明

本软件基于 **GNU General Public License v3.0 (GPL 3.0)** 许可证开源。

您可以自由地：
- **复制** — 复制和分发本软件
- **修改** — 对本软件进行修改
- **再分发** — 分发修改后的版本

但必须遵守以下条款：
- **提供源代码** — 分发时必须同时提供完整的源代码
- **保留版权声明** — 必须保留原始版权声明
- **标注修改内容** — 必须明确标注对原作的修改
- **相同许可证** — 修改后的作品必须同样以 GPL 3.0 许可证发布

详细条款请参阅 [GPL 3.0 许可证全文](https://www.gnu.org/licenses/gpl-3.0.html)。

## 免责声明

本软件为同人作品，所有美术资源版权归属于欢乐互娱公司。本作品仅用于学习和交流目的，严禁任何形式的商业使用。如果您用于商业用途，由此产生的一切后果请自行承担。

## 安装与运行

本软件仅支持Windows平台，在release中下载并解压压缩包后，运行可执行文件即可开始游戏。游玩过程中请不要修改资源文件夹中的任何文件，否则造成的游戏崩溃等问题后果自负。

## 构建方式

如果使用YYC构建方式，请按照以下方式构建：
- 在 **GameMaker Studio2** 中打开此项目
- 下载 **Visual Studio** ，并安装MSVC v142生成工具
- 在GMS2中设置VS路径
- 点击构建-创建可执行文件即可

如果使用VM构建方式，则无需额外操作，直接构建即可

## 贡献指南

欢迎通过 fork 提交您的贡献！如果您希望参与开发，请遵循以下步骤：
1. Fork 本仓库；
2. 在 main 分支基础上创建您的功能分支；
3. 提交更改并发起 Pull Request。

## rt-shell 控制台

游戏内置开发者控制台（rt-shell），按 **F1** 打开/关闭。

- 直接输入文字即可聊天
- 输入help 可查看可使用的命令
- 联机需先通过 `connectpubserver ip [port] 房间名称` 连接中继服务器
- 需要在本地或者云端运行 relay_server.exe 或relay_server.py 启动中继服务器

## Python 脚本

### 依赖
- `lazyloading_migrate_sprites.py` — 无需额外安装
- `lazyloading_migrate_sprites_and_music_depth.py` — `pip install Pillow`，音频转换需 **ffmpeg**（放 `ffmpeg/ffmpeg.exe` 或系统 PATH）
- `lazyloading_restore_backup.py` — 无需额外安装

### 用法

**简单版** — 适合本地预览测试，速度快
```bash
python lazyloading_migrate_sprites.py
```
精灵→`get_load_sprite("xxx")`，音乐→`mus_menu` 默认

**深度版** — 适合正式构建发布，精灵预合并条带 + 音乐转 OGG
```bash
python lazyloading_migrate_sprites_and_music_depth.py
```
精灵帧→`sprites_join/` 条带PNG，音乐→`backgroundmusic/` OGG，代码→`get_load_audio("xxx")`

**还原**
```bash
python lazyloading_restore_backup.py [--keep-join]
```
> 两个迁移脚本互斥，切换需先还原。

## 问题反馈

如果您在使用过程中遇到问题，或有改进建议，欢迎通过 Issues 页面提交反馈。

---
**注意**：本项目为爱好者作品，与官方无关。请支持官方正版游戏。