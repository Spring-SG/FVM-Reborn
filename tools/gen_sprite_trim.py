# -*- coding: utf-8 -*-
"""
生成 scripts/sprite_trim_get/sprite_trim_get.gml（敌人贴图「不透明包围盒」表）。

为什么需要这张表：
  这批老鼠 / BOSS 贴图的画布留白极不统一（内容占画布 0.12~0.90，画布底部留白 0~467px），
  预览时如果按整张画布居中贴底，留白大的贴图会整个飘出裁剪框。所以离线量出每张图
  第 0 帧的 alpha 包围盒，绘制时用 draw_sprite_part_ext 只贴可见部分。

⚠️ 关键：第 0 帧必须从 .yy 的 Keyframes 顺序里读，不能拿「文件名排序第一个」——
   PNG 文件名是 GUID，和帧序无关。早先图省事用文件名排序，量到的是随机一帧
  （常是炸弹/特效帧），结果预览里一堆老鼠只剩一小块。

用法（在项目根目录）：
  python tools/gen_sprite_trim.py

新增敌人美术后重跑一次即可；脚本会就地重写 sprite_trim_get.gml。
"""

import os
import re
import sys
import glob

try:
    from PIL import Image
except ImportError:
    sys.exit("需要 Pillow：pip install pillow")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENEMY_INIT = os.path.join(ROOT, "scripts", "enemy_init", "enemy_init.gml")
OUT_GML = os.path.join(ROOT, "scripts", "sprite_trim_get", "sprite_trim_get.gml")

HEAD = '''/// @function sprite_trim_get(_spr)
/// @desc 取精灵第 0 帧的**不透明包围盒**（sprite 像素坐标），返回 [x, y, w, h]；无记录时返回 undefined。
///
///       为什么需要这张表：这批老鼠 / BOSS 贴图的画布留白极不统一（实测内容占画布 0.12~0.9），
///       按画布居中贴底会让 hot_vajra、magician_mouse、travel_record 这类"画布巨大、内容偏上"的
///       贴图整个飘出预览框。所以贴之前先按内容包围盒裁一刀，再按统一缩放绘制。
///
///       ⚠️ 表由 tools/gen_sprite_trim.py 离线生成（读 .yy 的 Keyframes 顺序拿第 0 帧，
///          不能按 PNG 文件名排序 —— 文件名是 GUID，和帧序无关）。
///          新增敌人美术后重跑该脚本即可；查不到名字时函数返回 undefined，
///          绘制会退回"整张画布"的老行为，不会报错。
/// @param {Asset.GMSprite} _spr
function sprite_trim_get(_spr)
{
	if (!sprite_exists(_spr)) return undefined;
	if (!variable_global_exists("sprite_trim_bounds")){
		global.sprite_trim_bounds = {
'''

TAIL = '''		};
	}
	return global.sprite_trim_bounds[$ sprite_get_name(_spr)];
}
'''


def frame0_png(sprite_name):
    """按 .yy 里 Keyframes 的顺序取第 0 帧对应的 PNG 路径。"""
    yy = os.path.join(ROOT, "sprites", sprite_name, sprite_name + ".yy")
    if not os.path.exists(yy):
        return None
    with open(yy, encoding="utf-8-sig") as f:
        s = f.read()
    i = s.find('"$KeyframeStore<SpriteFrameKeyframe>"')
    if i < 0:
        return None
    m = re.search(r'"name":"([0-9a-f-]{36})"', s[i:])
    if not m:
        return None
    p = os.path.join(ROOT, "sprites", sprite_name, m.group(1) + ".png")
    return p if os.path.exists(p) else None


def main():
    with open(ENEMY_INIT, encoding="utf-8") as f:
        src = f.read()
    names = sorted(set(re.findall(r'"spr":([A-Za-z0-9_]+)', src)))

    lines = []
    skipped = []
    for name in names:
        png = frame0_png(name)
        if not png:
            skipped.append((name, "找不到第 0 帧"))
            continue
        im = Image.open(png).convert("RGBA")
        bb = im.getbbox()
        if bb is None:
            skipped.append((name, "第 0 帧全透明"))
            continue
        x, y, x2, y2 = bb
        lines.append('\t\t\t"%s": [%d, %d, %d, %d],' % (name, x, y, x2 - x, y2 - y))

    with open(OUT_GML, "w", encoding="utf-8", newline="") as f:
        f.write(HEAD + "\n".join(lines) + "\n" + TAIL)

    print("写入 %s" % os.path.relpath(OUT_GML, ROOT))
    print("  条目 %d，跳过 %d" % (len(lines), len(skipped)))
    for n, why in skipped:
        print("  - %s（%s，退回整张画布）" % (n, why))


if __name__ == "__main__":
    main()
