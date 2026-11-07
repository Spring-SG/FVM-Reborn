# -*- coding: utf-8 -*-
"""
生成 scripts/level_hashes/level_hashes.gml —— 内置关卡文件的哈希表。

为什么需要这张表：
  GameMaker 的 buffer_load / file_text_* 在权限、杀毒软件、路径含中文等情况下会
  **静默读取失败**（返回空内容或半截内容而不报错），关卡数据一旦读坏，战斗会直接从
  错误的网格/波次上运行，且没有任何提示。所以每次读关卡时把内存里读到的内容按同一
  套算法算一遍哈希，与这里离线算好的值比对，不一致就拒绝加载。

为什么不放在 datafiles 里：
  datafiles 本身也会被静默读坏 —— 用它做校验基准等于用不可信的数据校验不可信的数据。
  表必须是编译进游戏的 GML 资源。

哈希算法（必须和 GML 端 scripts/level_integrity 完全一致）：
  逐字节 FNV 风格双 32 位混合（rotate/xor/add，不使用 64 位乘法，避免 double 精度问题），
  跳过空格、\\t、\\n、\\r —— 于是哈希只和 JSON 的语义字节有关，
  不受缩进、CRLF/LF 差异影响（.gitattributes 把 *.json 归一成 LF，Windows 检出又是 CRLF，
  两种检出的字节数不一样，所以这里必须对空白免疫）。
  最后把「参与哈希的字节数」也混进去，这样读到半截内容时即使前缀相同也能被识别。
  尾部 \\x00（关卡文件末尾普遍带一个终止符）不计入。

用法（在项目根目录）：
  python tools/gen_level_hashes.py            # 重新生成表
  python tools/gen_level_hashes.py --check    # 只比对，不写文件（有差异则退出码 1）

改过任何 datafiles/level_data 下的关卡 JSON 之后都要重跑一次，否则游戏会判定
关卡文件损坏而拒绝加载。
"""

import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEVEL_DIR = os.path.join(ROOT, "datafiles", "level_data")
OUT_GML = os.path.join(ROOT, "scripts", "level_hashes", "level_hashes.gml")

MASK = 0xFFFFFFFF
SEED1 = 0x811C9DC5
SEED2 = 0x9E3779B9
SKIP = (0x20, 0x09, 0x0A, 0x0D)  # 空格 \t \n \r

HEAD = u'''/// @description 内置关卡文件哈希表（由 tools/gen_level_hashes.py 自动生成，请勿手改）
/// @desc 键 = buffer_load 使用的路径（相对 datafiles 目录，正斜杠）；
///       值 = 内容哈希（逐字节双 32 位混合，忽略空格/制表/换行，尾部 NUL 不计入，
///       算法见 scripts/level_integrity）。
///       文件被改动、或 GameMaker 静默读坏时哈希对不上，level_load_json_verified
///       会拒绝加载并让玩家退回地图。改过关卡 JSON 后请重跑生成脚本。
/// @returns {Struct<String, String>}
function level_hashes_get(){
\tif (!variable_global_exists("lvl_hash_tbl")) {
\t\tglobal.lvl_hash_tbl = {
'''

TAIL = u'''\t\t}
\t}
\treturn global.lvl_hash_tbl
}
'''


def rotl32(x, n):
    x &= MASK
    return ((x << n) | (x >> (32 - n))) & MASK


def level_hash(data):
    """与 GML 端 level_integrity_hash_buffer 完全一致。data 为 bytes（整份文件）。"""
    end = len(data)
    while end > 0 and data[end - 1] == 0:      # 尾部 NUL 终止符不计入
        end -= 1
    h1 = SEED1
    h2 = SEED2
    count = 0
    for b in data[:end]:
        if b in SKIP:
            continue
        count += 1
        h1 = (h1 ^ b) & MASK
        h1 = rotl32(h1, 13)
        h1 = (h1 + (h1 << 5) + 0x7F4A7C15) & MASK
        h2 = (h2 + b + 0x165667B1) & MASK
        h2 = (h2 ^ (h2 >> 15)) & MASK
        h2 = (h2 * 3 + 0x85EBCA6B) & MASK
    h1 = (h1 + count) & MASK
    h2 = (h2 ^ count) & MASK
    return "%08x%08x" % (h1, h2)


def iter_level_files():
    for dirpath, _dirnames, filenames in os.walk(LEVEL_DIR):
        for name in sorted(filenames):
            if not name.lower().endswith(".json"):
                continue
            full = os.path.join(dirpath, name)
            rel = os.path.relpath(full, LEVEL_DIR).replace("\\", "/")
            yield full, "level_data/" + rel


def build_lines():
    rows = []
    for full, key in iter_level_files():
        with open(full, "rb") as f:
            raw = f.read()
        rows.append((key, level_hash(raw), len(raw)))
    rows.sort(key=lambda r: r[0])
    lines = []
    for key, h, _size in rows:
        lines.append(u'\t\t\t"%s": "%s",' % (key, h))
    return lines, rows


def main():
    ap = argparse.ArgumentParser(description=u"生成关卡文件哈希表")
    ap.add_argument("--check", action="store_true",
                    help=u"只比对磁盘上的关卡文件与已生成的表，不写文件")
    args = ap.parse_args()

    if not os.path.isdir(LEVEL_DIR):
        print(u"找不到关卡目录：%s" % LEVEL_DIR, file=sys.stderr)
        return 2

    lines, rows = build_lines()
    text = HEAD + u"\n".join(lines) + u"\n" + TAIL

    if args.check:
        old = u""
        if os.path.isfile(OUT_GML):
            with open(OUT_GML, encoding="utf-8", newline="") as f:
                old = f.read()
        if old == text:
            print(u"哈希表是最新的（%d 个关卡文件）" % len(rows))
            return 0
        print(u"哈希表与关卡文件不一致，请重跑 python tools/gen_level_hashes.py", file=sys.stderr)
        return 1

    os.makedirs(os.path.dirname(OUT_GML), exist_ok=True)
    with open(OUT_GML, "w", encoding="utf-8", newline="") as f:
        f.write(text)

    total = sum(r[2] for r in rows)
    print(u"写入 %s" % os.path.relpath(OUT_GML, ROOT))
    print(u"  条目 %d，合计 %d 字节" % (len(rows), total))
    return 0


if __name__ == "__main__":
    sys.exit(main())
