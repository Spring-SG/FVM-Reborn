# -*- coding: utf-8 -*-
"""
填充 cucur_pyramid_hard.json 的波次。

规则（描述里的波次编号从 1 开始，waves 数组下标从 0 开始）：
  1. 第 2-4 波（下标 1-3）：第 1-9 小波用随机沙漠敌人补到 21 个，已有敌人原样保留；
     第 10 小波（下标 9）整体替换为第 1 波第 10 小波的副本。
  2. 第 4 波复制到第 6、8、9 波（下标 5/7/8），只复制 subwaves，
     大波自身的 wave_index / boss_wave / boss / hp_modify 保持不变（第 9 波仍是 BOSS 波）。
  3. 第 5、7 波（下标 4/6，BOSS 波）留空不动。

写法与关卡文件原样保持一致：紧凑 JSON + 尾部 \\x00 终止符。
用法：python tools/fill_cucur_pyramid_hard.py [--seed N]
"""

import argparse
import copy
import json
import os
import random

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEVEL = os.path.join(ROOT, "datafiles", "level_data", "desert", "cucur_pyramid_hard.json")

TARGET_COUNT = 21          # 每个小波填充到的敌人数量
LAST_SUBWAVE = 9           # 第 10 小波（数组下标 9）
FILL_WAVES = (1, 2, 3)     # 第 2-4 波
COPY_SRC = 3               # 第 4 波
COPY_DST = (5, 7, 8)       # 第 6、8、9 波

# 沙漠组（group == "desert"）的非 BOSS 敌人，排除用户点名的 5 种
DESERT_POOL = [
    "skeleton_normal_mouse",    # 骷髅平民鼠
    "totem_shield_mouse",       # 图腾盾牌鼠
    "desert_mole",              # 沙漠鼹鼠
    "tribal_shaman_mouse",      # 部落萨满鼠
    "little_monster_mouse",     # 熊孩子鼠
    "cactus_mouse",             # 仙人球鼠
    "desert_witch_mouse",       # 沙漠巫术鼠
    "javelin_giant_mouse",      # 标枪巨人鼠
]
EXCLUDED = {
    "tribe_normal_mouse", "sandboarding_mouse", "primordial_giant_mouse",
    "trojan_horse", "hot_ballon_mouse",
}


def load():
    with open(LEVEL, "rb") as f:
        raw = f.read()
    return json.loads(raw.rstrip(b"\x00").decode("utf-8"))


def save(data):
    out = json.dumps(data, ensure_ascii=False, separators=(",", ":")).encode("utf-8") + b"\x00"
    with open(LEVEL, "wb") as f:
        f.write(out)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=20261117)
    args = ap.parse_args()

    assert not (set(DESERT_POOL) & EXCLUDED), "填充池里混进了被排除的敌人"
    rng = random.Random(args.seed)
    data = load()
    waves = data["waves"]

    # 1) 第 2-4 波：小波 1-9 补到 21
    for wi in FILL_WAVES:
        for si, sub in enumerate(waves[wi]["subwaves"]):
            if si == LAST_SUBWAVE:
                continue
            lst = sub["enemy_list"]
            while len(lst) < TARGET_COUNT:
                lst.append({
                    "type": rng.choice(DESERT_POOL),
                    "row": -1.0,          # -1 = 让引擎分配行，与本关卡已有条目一致
                    "prosperity": 0.0,
                })

    # 2) 第 2-4 波：第 10 小波 = 第 1 波第 10 小波的副本
    src_last = waves[0]["subwaves"][LAST_SUBWAVE]
    for wi in FILL_WAVES:
        waves[wi]["subwaves"][LAST_SUBWAVE] = copy.deepcopy(src_last)

    # 3) 第 4 波复制到第 6、8、9 波（只换 subwaves，保住第 9 波的 BOSS 身份）
    src_subs = copy.deepcopy(waves[COPY_SRC]["subwaves"])
    for wi in COPY_DST:
        waves[wi]["subwaves"] = copy.deepcopy(src_subs)

    save(data)
    print("已写入 %s（seed=%d）" % (os.path.relpath(LEVEL, ROOT), args.seed))
    for wi, w in enumerate(waves):
        counts = [len(s["enemy_list"]) for s in w["subwaves"]]
        print("  第%d波 index=%s boss=%-18s subwaves=%d 敌人/小波=%s"
              % (wi + 1, w["wave_index"], repr(w["boss"]), len(w["subwaves"]), counts))


if __name__ == "__main__":
    main()
