# 美食大战老鼠：重生

《美食大战老鼠：重生》是一款基于 GameMaker 引擎重新编写的《美食大战老鼠》同人游戏，旨在回归塔防初衷，优化不合理的游戏体验。

---

## 📋 目录

- [美食大战老鼠：重生](#美食大战老鼠重生)
  - [📋 目录](#-目录)
  - [软件简介](#软件简介)
  - [分支说明](#分支说明)
  - [权限声明](#权限声明)
  - [免责声明](#免责声明)
  - [安装与运行](#安装与运行)
  - [构建方式](#构建方式)
    - [前置要求](#前置要求)
    - [命令行一键构建（推荐）](#命令行一键构建推荐)
    - [在 GameMaker 中手动构建](#在-gamemaker-中手动构建)
    - [Windows 动态库构建](#windows-动态库构建)
  - [工具脚本](#工具脚本)
    - [gen_level_hashes.py](#gen_level_hashspy)
    - [gen_sprite_trim.py](#gen_sprite_trimpy)
    - [enable_bc7.py](#enable_bc7py)
    - [fill_cucur_pyramid_hard.py](#fill_cucur_pyramid_hardpy)
  - [贡献指南](#贡献指南)
  - [问题反馈](#问题反馈)

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

本仓库中我们自制的贴图和文案由**CC BY-NC-SA**协议授权。这些内容包括：
- 所有的关卡气泡贴图
- 设置菜单和编辑菜单贴图
- 软件图标和游戏主标题贴图
- 情报岛内的详细介绍文案

这代表你使用这些贴图和文案时，需要遵守以下条款：
- **署名** - 必须注明来源。
- **非商用** - 不得用于商业用途。
- **相同方式共享** - 允许修改创作，但衍生作品必须使用与原作品完全相同的许可协议。

其余原版贴图和文案版权属于欢乐互娱公司，使用时需要遵守原权利方协议。

详情参见 [CC BY-NC-SA协议条款](https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode.en)

## 免责声明

本软件为同人作品，所有原版美术资源版权归属于欢乐互娱公司。本作品仅用于学习和交流目的，严禁任何形式的商业使用。如果您用于商业用途，由此产生的一切后果请自行承担。

## 安装与运行

本软件仅支持Windows平台，在release中下载并解压压缩包后，运行可执行文件即可开始游戏。游玩过程中请不要修改资源文件夹中的任何文件，否则造成的游戏崩溃等问题后果自负。

## 构建方式

### 前置要求

| 依赖 | 说明 |
| --- | --- |
| **GameMaker** | 需安装 IDE 与对应运行时（当前开发环境为 runtime `2024.14.4.x`） |
| **Visual Studio 2019/2022** | 仅 YYC 构建需要，须勾选「使用 C++ 的桌面开发」工作负载（MSVC v142） |
| **Python 3** | 运行 `tools/` 下的生成脚本；命令需为 `py -3` 或 `python` |
| **Pillow** | 仅 `gen_sprite_trim.py` 需要，`pip install pillow` |

VM 构建无需 Visual Studio，其余依赖与上表一致。

### 命令行一键构建（推荐）

项目自带 `tools/build.bat`，在仓库根目录执行（或直接双击）即可完成一次完整构建：

``` bat
tools\build.bat
```

脚本按三步执行：

1. **重跑数据表生成脚本** —— `gen_level_hashes.py`（关卡哈希表）、`gen_sprite_trim.py`（敌人贴图包围盒表）。任一步失败会立即中止，避免带着过期的哈希表打包。
2. **清理上一次的构建产物** —— 父目录下的 `output\FVM-reborn`（上次的 `data.win` / exe / dll）以及 `build_out\*.zip`、`*.log`。
3. **调用 Igor 命令行 + YYC 编译打包**，产物为 `build_out\FVM-reborn_yyc.zip`。

脚本会自动从 `ProgramData` 里挑最新的可用的 runtime，并从 `%APPDATA%\GameMakerStudio2*` 下找含 `licence.plist` 的用户目录，通常无需任何配置。

常用参数：

| 参数 | 作用 |
| --- | --- |
| 无参数 | 默认：清理产物 + 增量 YYC 构建（最快，热缓存约 3 分钟） |
| `-noclean` | 什么都不删，连增量产物也保留 |
| `-deepclean` | 额外物理删除 `cache\FVM-reborn`，强制全量重建（冷缓存约 13 分钟，仅怀疑缓存损坏时用） |
| `-vm` | 改用 VM 构建，不跑 C++ 编译，适合只验证 GML 逻辑 |
| `-log` | Igor 输出写入 `build_out\igor_build.log`（构建期间控制台无进度） |
| `-nobuild` | 只跑生成脚本 + 清理，不真正构建 |

可选环境变量（仅当自动探测失败时需要手动指定）：

| 变量 | 说明 |
| --- | --- |
| `PYTHON` | Python 解释器命令，默认先找 `py -3` 再找 `python` |
| `GM_RUNTIME` | 运行时根目录，如 `C:\ProgramData\GameMakerStudio2\Cache\runtimes\runtime-2024.14.4.268` |
| `GM_USER_FOLDER` | 含 `licence.plist` 的用户目录 |

> **注意**
> - 构建前请关闭 GameMaker IDE，否则 `output\` 与 `cache\` 下的文件被占用会导致清理或编译失败。
> - 只拿到 zip 想实机验证时，解压后直接运行 `FVM_Reborn.exe` 即可；存档写入 `%LOCALAPPDATA%\FVM_Reborn\`，因此**不要**把游戏放在需要管理员权限的目录。
> - `build.bat` 必须保持 **GBK(936) 编码 + CRLF 行尾**，改成 UTF-8 或 LF 会让 cmd 解析错位。

### 在 GameMaker 中手动构建

如果想在 IDE 里构建，按以下步骤操作：

- 在 **GameMaker** 中打开本项目（`FVM-reborn.yyp`）
- 若使用 YYC：下载 **Visual Studio** 并安装 MSVC v142 生成工具，然后在 GameMaker 的「文件 - 首选项 - 平台 - Windows」中设置 VS 路径
- 点击「构建 - 创建可执行文件」即可

如果使用 VM 构建，则无需额外配置，直接构建即可。

### Windows 动态库构建

由于使用到了 [7zip](https://github.com/ip7z/7zip) 来解压文件，引入了 git submodule，如果需要构建 windows 的原生动态库，则需要先执行

``` bash
git submodule update --init --recursive
```

## 工具脚本

`tools/` 下是开发期用的辅助脚本。除 `build.bat` 外均为 Python 脚本，**一律在仓库根目录执行**（脚本自身按文件位置定位项目根，路径不用改）。

> 生成类脚本（`gen_level_hashes.py`、`gen_sprite_trim.py`）的输出会被编译进游戏，**不要手改**产物，需要更新就重跑脚本。

### gen_level_hashes.py

生成 `scripts/level_hashes/level_hashes.gml` —— 内置关卡文件的哈希表。

``` bash
python tools/gen_level_hashes.py           # 重新生成
python tools/gen_level_hashes.py --check   # 只比对，不写文件；有差异退出码为 1
```

**改了 `datafiles/level_data/` 下任何关卡 JSON 之后必须重跑**，否则游戏读到的哈希与内置表不一致，会判定文件损坏并拒绝加载、把玩家退回地图。

说明：

- 之所以要这张表，是因为 GameMaker 的 `buffer_load` 在权限、杀毒软件、中文路径等情况下会**静默读坏**（返回空或半截内容却不报错），关卡数据一旦读坏，战斗会直接从错误的网格/波次上运行且毫无提示。
- 表放在 GML 资源里而不是 `datafiles/`，因为 `datafiles` 本身也可能被读坏——不能拿不可信数据当校验基准。
- 哈希算法为逐字节双 32 位混合，**跳过空格、`\t`、`\n`、`\r`**，因此对缩进和 CRLF/LF 差异免疫；末尾的 `\x00` 终止符不计入。算法须与 `scripts/level_integrity` 保持一致，改动任一侧都要同步。
- 想在测试版跳过关卡校验，可把 `obj_game_init` 的 `global.level_hash_verify` 设为 `false`。

### gen_sprite_trim.py

生成 `scripts/sprite_trim_get/sprite_trim_get.gml` —— 敌人贴图的**不透明包围盒**表。

``` bash
python tools/gen_sprite_trim.py
```

敌人列表取自 `scripts/enemy_init` 中的 `"spr":` 字段，脚本逐张读取**第 0 帧**的 alpha 包围盒。绘制时用 `draw_sprite_part_ext` 只贴可见部分，避免留白极大的贴图在预览里飘出裁剪框。缺少 Pillow 时脚本会直接报错退出；查不到记录的精灵会退回「整张画布」的旧行为，不会崩溃。

**新增或替换敌人美术后重跑一次即可。** 注意第 0 帧必须按 `.yy` 里 `Keyframes` 的顺序取，`sprites/` 下的 PNG 文件名是 GUID，按文件名排序会量到随机一帧。

### enable_bc7.py

把纹理压缩从 bz2 切换到 BC7（接入 `extensions/TextureEncode`），或切回去。

``` bash
python tools/enable_bc7.py            # 全部纹理组切到 BC7（BCN -u2）
python tools/enable_bc7.py --revert   # 切回 bz2
```

脚本只做两件事：在 `.yyp` 的 `resources` 里补上扩展条目（已存在则跳过），以及把 `TextureGroups` 段里每个组的 `compressFormat` / `customOptions` 改成目标值。**改完必须重新构建**才会生效，且首次切换后所有纹理页会重新编码。

实测收益（14 个纹理组）：

| 项目 | bz2 | BC7 |
| --- | --- | --- |
| 发布 zip | 1187 MB | 737 MB |
| 主菜单显存占用 | 1594 MB | 597 MB |
| `data.win` | 943 MB | 1149 MB |

`data.win` 变大是因为 BC7 裸块比 bz2 页大，但前者能被 deflate 压掉近一半，整体仍是净收益。质量档由脚本内的 `QUALITY` 控制（`-u0`～`-u4`，数值越大越慢、边缘越干净）；若要发布到 macOS/mobile，需改用 BC3（`-3`）。

### fill_cucur_pyramid_hard.py

重填沙漠关卡 `cucur_pyramid_hard.json` 的波次配置，属于一次性的关卡数据加工脚本。

``` bash
python tools/fill_cucur_pyramid_hard.py            # 默认 seed=20261117
python tools/fill_cucur_pyramid_hard.py --seed N   # 换随机种子
```

规则：第 2～4 波的前 9 个小波用沙漠组敌人随机补到 21 个（保留原有敌人），第 10 个小波整体替换为第 1 波第 10 小波的副本；第 4 波的小波复制到第 6、8、9 波（只换 `subwaves`，第 9 波仍保持 BOSS 波身份）；第 5、7 波这两个 BOSS 波保持不动。写回时沿用原文件的紧凑 JSON + 尾部 `\x00` 格式。

**这个脚本会覆盖关卡文件，运行后记得再跑一次 `gen_level_hashes.py`**（`build.bat` 已自动包含这一步）。

## 贡献指南

欢迎通过 fork 提交您的贡献！如果您希望参与开发，请遵循以下步骤：
1. Fork 本仓库；
2. 在 main 分支基础上创建您的功能分支；
3. 提交更改并发起 Pull Request。

## 问题反馈

如果您在使用过程中遇到问题，或有改进建议，欢迎通过 Issues 页面提交反馈。

---
**注意**：本项目为爱好者作品，与官方无关。请支持官方正版游戏。