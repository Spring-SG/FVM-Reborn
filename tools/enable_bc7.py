# -*- coding: utf-8 -*-
"""把 GM-GPUTextureCompression 的 TextureEncode 扩展接进项目，并把所有纹理组切到 BC7。

只做两件事：
  1. .yyp 的 resources 数组里加一条扩展条目（照 WindowsNative 的写法）
  2. TextureGroups 段里每个组：compressFormat bz2 -> custom，customOptions "" -> BCN -u2

用法：python tools/enable_bc7.py [--revert]
  --revert  改回 bz2 / 空 customOptions（扩展条目保留，便于再切回去）
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
YYP = os.path.join(ROOT, "FVM-reborn.yyp")
QUALITY = "BCN -u2"          # BC7 medium；-u3/-u4 更慢但边缘更干净

REVERT = "--revert" in sys.argv


def main():
    s = open(YYP, encoding="utf-8-sig", newline="").read()
    orig = s

    # ---- 1. 注册扩展（只在缺的时候加，避免重复）----
    if '"TextureEncode"' not in s:
        anchor = '    {"id":{"name":"WindowsNative","path":"extensions/WindowsNative/WindowsNative.yy",},},\n'
        assert anchor in s, "找不到 WindowsNative 资源条目，.yyp 结构变了？"
        s = s.replace(
            anchor,
            anchor + '    {"id":{"name":"TextureEncode","path":"extensions/TextureEncode/TextureEncode.yy",},},\n',
            1,
        )

    # ---- 2. 只处理 TextureGroups 段 ----
    # 注意：这个 .yyp 里 AudioGroups 排在 TextureGroups 前面（按字母序），
    # 所以不能用 AudioGroups 当右边界，要找同缩进的数组结尾 "  ],"
    i = s.find('"TextureGroups":[')
    j = s.find('\n  ],', i)
    assert i > 0 and j > i, "找不到 TextureGroups 段边界"
    seg = s[i:j]

    if REVERT:
        new_seg = seg.replace('"compressFormat":"custom"', '"compressFormat":"bz2"')
        new_seg = new_seg.replace('"customOptions":"%s"' % QUALITY, '"customOptions":""')
    else:
        new_seg = seg.replace('"compressFormat":"bz2"', '"compressFormat":"custom"')
        new_seg = new_seg.replace('"customOptions":""', '"customOptions":"%s"' % QUALITY)

    n_fmt = new_seg.count('"compressFormat":"%s"' % ("bz2" if REVERT else "custom"))
    n_opt = new_seg.count('"customOptions":"%s"' % ("" if REVERT else QUALITY))

    s = s[:i] + new_seg + s[j:]

    if s == orig:
        print("没有变化（可能已经是目标状态）")
        return 0

    open(YYP, "w", encoding="utf-8", newline="").write(s)
    print("已写入 %s" % os.path.basename(YYP))
    print("  纹理组 compressFormat=%s：%d 个；customOptions=%r：%d 个"
          % ("bz2" if REVERT else "custom", n_fmt, "" if REVERT else QUALITY, n_opt))
    return 0


if __name__ == "__main__":
    sys.exit(main())
