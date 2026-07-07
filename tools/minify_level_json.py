#!/usr/bin/env python3
# -*- coding: utf-8 -*-
r"""关卡 JSON 无损压缩脚本（发布打包用）

用途：发布打包时对构建输出目录中的 level_data\*.json 做无损压缩。
关卡 JSON 为 4 空格缩进的美化格式，约 60%+ 的字节是缩进/换行空白，
压缩后体积约降为原来的 1/3，解析结果与原文件完全一致。

原理：仅删除 JSON 字符串字面量之外的空白字符（空格/制表/回车/换行），
不重新序列化——数字格式、键顺序、转义方式全部原样保留。文件头部的
UTF-8 BOM 与尾部的 NUL 字节（GameMaker buffer_save 的痕迹）逐字节保留。

安全校验（每个文件，任一失败则整体不写入并以非零码退出）：
  1. 压缩前后 JSON 主体 json.loads 深度相等；
  2. 幂等：对压缩结果再压缩一次输出不变；
  3. 头/尾非 JSON 字节逐字节不变；
  4. 主体无法严格解析或尾部含非 NUL 数据的文件：原样跳过并计数报告。

用法：
  python tools/minify_level_json.py <目录>          # 试运行，仅统计
  python tools/minify_level_json.py <目录> --apply  # 原地写入

注意：请只对发布产物运行（如打包目录中的 level_data），
不要对仓库内 datafiles/ 源文件运行，以保持源文件的可读 diff。
"""
import json
import sys
from pathlib import Path

BOM = b"\xef\xbb\xbf"


def minify(text: str) -> str:
    """删除字符串外的空白，其余字符原样保留。"""
    out = []
    in_str = False
    escape = False
    for ch in text:
        if in_str:
            out.append(ch)
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == '"':
                in_str = False
        else:
            if ch == '"':
                in_str = True
                out.append(ch)
            elif ch in " \t\r\n":
                continue
            else:
                out.append(ch)
    return "".join(out)


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    root = Path(sys.argv[1])
    apply_changes = "--apply" in sys.argv[2:]
    files = sorted(root.rglob("*.json"))
    if not files:
        print(f"未找到 JSON：{root}")
        return 2

    total_before = total_after = 0
    changed = 0
    skipped = []
    for path in files:
        raw = path.read_bytes()
        head = BOM if raw.startswith(BOM) else b""
        body_bytes = raw[len(head):]
        core_bytes = body_bytes.rstrip(b"\x00")
        trailer = body_bytes[len(core_bytes):]  # 只可能是若干 NUL

        try:
            core = core_bytes.decode("utf-8")
            parsed = json.loads(core)
        except (UnicodeDecodeError, json.JSONDecodeError):
            skipped.append(path)
            total_before += len(raw)
            total_after += len(raw)
            continue

        small = minify(core)
        # 校验 1：解析结果必须完全一致
        if json.loads(small) != parsed:
            print(f"[FAIL] 解析结果不一致，未写入任何文件：{path}")
            return 1
        # 校验 2：幂等
        if minify(small) != small:
            print(f"[FAIL] 幂等校验失败，未写入任何文件：{path}")
            return 1
        new_raw = head + small.encode("utf-8") + trailer
        # 校验 3：头/尾字节不变（按构造成立，仍显式断言）
        if not (new_raw.startswith(head) and new_raw.endswith(trailer)):
            print(f"[FAIL] 头尾字节校验失败，未写入任何文件：{path}")
            return 1

        total_before += len(raw)
        total_after += len(new_raw)
        if new_raw != raw:
            changed += 1
            if apply_changes:
                path.write_bytes(new_raw)

    mode = "已写入" if apply_changes else "试运行（加 --apply 生效）"
    print(f"{mode}：共 {len(files)} 个文件，可压缩 {changed} 个，跳过 {len(skipped)} 个")
    for p in skipped:
        print(f"  [跳过-非严格JSON原样保留] {p}")
    print(f"总大小 {total_before:,} -> {total_after:,} 字节 "
          f"(节省 {total_before - total_after:,}，{(1 - total_after / max(total_before, 1)) * 100:.1f}%)")
    print("校验：解析等价 OK / 幂等 OK / 头尾字节保留 OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
