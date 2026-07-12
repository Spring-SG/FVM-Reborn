"""
精灵 & 音乐迁移脚本
--------------------
精灵：Enemy/Cards/Maps 目录下的精灵 → 删 .yyp、替换 object .yy spriteId、替换 .gml 常量
音乐：所有 mus_* 音乐 → 删 .yyp、替换 .gml 常量
所有改动先存 .bak，白名单内的跳过。
"""

import json
import re
import os
import shutil
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent
os.chdir(PROJECT_ROOT)

# ── 配置 ──────────────────────────────────────────────

REPLACE_SPRITE = 'spr_cloud_daytime'   # object .yy spriteId 替换默认值
REPLACE_AUDIO  = 'mus_menu'             # 音乐替换默认值

SPRITE_FOLDERS = [
    'folders/精灵/Enemy/',
    'folders/精灵/Cards/',
    'folders/精灵/Maps/',
    'folders/精灵/UI/Attire/',
]

# 白名单：这些精灵/音乐跳过不处理
SKIP_SPRITES = {
    'spr_town',
    'spr_reday_room',
    'spr_delicious_islands',
    'spr_salad_island_land',
}

SKIP_AUDIO = {
    'mus_menu',
    'mus_readyroom',
    'mus_town',
}

MAX_STRIP_WIDTH = 16384  # GPU 纹理上限，超出则不迁移（sprite_add 单行条带限制）


# ── 工具函数 ──────────────────────────────────────────

def clean_trailing_commas(text: str) -> str:
    return re.sub(r',(\s*[}\]])', r'\1', text)


def parse_gm_json(filepath: Path) -> dict:
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.loads(clean_trailing_commas(f.read()))


def backup_if_needed(filepath: Path) -> bool:
    bak = Path(str(filepath) + '.bak')
    if bak.exists():
        return False
    shutil.copy2(filepath, bak)
    print(f'  [bak]  {bak.name}')
    return True


# ── 第 1 步：收集目标 ─────────────────────────────────

print('=' * 60)
print('第 1 步：收集需要处理的资源')
print('=' * 60)

# 从 .yyp 找所有精灵条目，读各自 .yy 拿 parent 判断类别
yyp_path = Path('FVM-reborn.yyp')
yyp_data = parse_gm_json(yyp_path)

target_sprites: set[str] = set()
sprite_paths: dict[str, str] = {}  # name → .yy path
cat_counts: dict[str, int] = {}

# 第一遍：收集目标精灵名和所属分类
for res in yyp_data['resources']:
    rid = res.get('id', {})
    name = rid.get('name', '')
    path = rid.get('path', '')
    if not path.startswith('sprites/') or name in SKIP_SPRITES:
        continue
    sprite_yy = Path(path)
    if not sprite_yy.exists():
        continue
    info = parse_gm_json(sprite_yy)
    parent = info.get('parent', '')
    if isinstance(parent, dict):
        parent = parent.get('path', '')
    for folder in SPRITE_FOLDERS:
        if parent.startswith(folder):
            target_sprites.add(name)
            sprite_paths[name] = path
            cat = folder.split('/')[2]
            if 'UI/' in parent:
                cat = 'UI/Attire'
            cat_counts[cat] = cat_counts.get(cat, 0) + 1
            break

# 第二遍：构建详细信息
removed_sprites: dict[str, dict] = {}
oversize_skip: set[str] = set()
for name in sorted(target_sprites):
    path = sprite_paths[name]
    info = parse_gm_json(Path(path))
    raw_frames = info.get('frames', [])
    if not raw_frames:
        layers = info.get('layers', [])
        if layers:
            raw_frames = layers[0].get('frames', [])
    frames_list = [f['name'] if isinstance(f, dict) else f for f in raw_frames]
    dir_path = '/'.join(path.replace('\\', '/').split('/')[:-1]) if '/' in path else path

    # 跳过 strip 宽度超出 GPU 纹理上限的精灵（sprite_add 单行条带限制）
    _w = info.get('width', 0)
    _fc = info.get('frameCount', len(frames_list) or 1)
    if _w * _fc > MAX_STRIP_WIDTH:
        oversize_skip.add(name)
        continue

    seq = info.get('sequence', {}) or {}

    removed_sprites[name] = {
        'width':         info.get('width', 0),
        'height':        info.get('height', 0),
        'xorigin':       info.get('xorigin', 0) or seq.get('xorigin', 0) or 0,
        'yorigin':       info.get('yorigin', 0) or seq.get('yorigin', 0) or 0,
        'frameCount':    info.get('frameCount', len(frames_list) or 1),
        'frames':        frames_list,
        'fps':           info.get('fps') or info.get('speed') or seq.get('playbackSpeed') or 30,
        'collisionKind': min(info.get('collisionKind', 0), 3),
        'collisionTolerance': info.get('collisionTolerance', 0),
        'bbox': [
            info.get('bbox_left', 0),
            info.get('bbox_top', 0),
            info.get('bbox_right', 0),
            info.get('bbox_bottom', 0),
        ],
        'textureGroup':  info.get('textureGroupId', {}).get('name', '') if isinstance(info.get('textureGroupId'), dict) else '',
        'path':          dir_path,
    }

# 剔除超出纹理上限的精灵（sprite_add 单行条带限制）
if oversize_skip:
    target_sprites -= oversize_skip
    print(f'  跳过(超宽): {len(oversize_skip)} 个')
    for n in sorted(oversize_skip):
        print(f'    - {n}')

print(f'  Enemy:  {cat_counts.get("Enemy", 0)} 个')
print(f'  Cards:  {cat_counts.get("Cards", 0)} 个')
print(f'  Maps:   {cat_counts.get("Maps", 0)} 个')
print(f'  白名单: {len(SKIP_SPRITES)} 个')
print(f'  精灵合计: {len(target_sprites)} 个')

# ── 音乐：从 .yyp 收集所有 mus_* ──────────────────────

print('-' * 40)
print('音乐资源:')
print('-' * 40)

target_audio: set[str] = set()
for res in yyp_data['resources']:
    rid = res.get('id', {})
    name = rid.get('name', '')
    path = rid.get('path', '')
    if path.startswith('sounds/') and name.startswith('mus_') and name not in SKIP_AUDIO:
        target_audio.add(name)

print(f'  音乐: {len(target_audio)} 个')
print(f'  白名单: {len(SKIP_AUDIO)} 个')
print()

# ── 第 2 步：处理 .yyp ────────────────────────────────

print('=' * 60)
print('第 2 步：清理 FVM-reborn.yyp')
print('=' * 60)

backup_if_needed(Path('FVM-reborn.yyp'))

with open('FVM-reborn.yyp', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines: list[str] = []
removed_sprite = 0
removed_audio = 0

for line in lines:
    # 精灵
    m = re.search(r'"name":"(spr_[^"]+)","path":"sprites/', line)
    if m and m.group(1) in target_sprites:
        removed_sprite += 1
        continue
    # 音乐
    m = re.search(r'"name":"(mus_[^"]+)","path":"sounds/', line)
    if m and m.group(1) in target_audio:
        removed_audio += 1
        continue
    new_lines.append(line)

with open('FVM-reborn.yyp', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)

print(f'  精灵: -{removed_sprite}  音乐: -{removed_audio}')
print()

# ── 第 3 步：处理 object .yy ──────────────────────────

print('=' * 60)
print('第 3 步：清理 object .yy 中的 spriteId 引用')
print('=' * 60)

object_sprite_map: dict[str, str] = {}
obj_mod = 0
obj_skip = 0

for yy_file in sorted(Path('objects').glob('**/*.yy')):
    data = parse_gm_json(yy_file)

    if data.get('resourceType') != 'GMObject':
        continue

    sid = data.get('spriteId')
    if not sid:
        continue

    sname = sid.get('name', '')
    if sname not in target_sprites:
        obj_skip += 1
        continue

    oname = data.get('name', '')
    object_sprite_map[oname] = sname

    backup_if_needed(yy_file)
    data['spriteId'] = {
        'name': REPLACE_SPRITE,
        'path': f'sprites/{REPLACE_SPRITE}/{REPLACE_SPRITE}.yy'
    }

    with open(yy_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    obj_mod += 1
    print(f'  [obj]  {oname}  ({sname} -> {REPLACE_SPRITE})')

print()
print(f'  修改 {obj_mod} 个, 跳过 {obj_skip} 个')
print()

# ── 第 4 步：处理 .gml ────────────────────────────────

print('=' * 60)
print('第 4 步：替换 .gml 中的精灵/音乐常量')
print('=' * 60)

SPR_RE = re.compile(r'(?<![."\'\w])(spr_\w+)(?![.\"\'\w])')
AUD_RE = re.compile(r'(?<![."\'\w])(mus_\w+)(?![.\"\'\w])')

gml_files  = list(Path('scripts').glob('**/*.gml'))
gml_files += list(Path('objects').glob('**/*.gml'))
gml_files  = sorted(set(gml_files))

gml_mod = 0
total_repl = 0

for gml_file in gml_files:
    with open(gml_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 收集命中的目标
    hits: list[tuple[str, int]] = []
    for m in SPR_RE.finditer(content):
        if m.group(1) in target_sprites:
            hits.append((m.group(1), 0))
    for m in AUD_RE.finditer(content):
        if m.group(1) in target_audio:
            hits.append((m.group(1), 1))

    if not hits:
        continue

    backup_if_needed(gml_file)

    # 统一替换为 get_load_sprite("spr_xxx")，返回占位 ID，hook 层翻译
    def repl_cb(m):
        name = m.group(1)
        if name in target_sprites:
            return f'get_load_sprite("{name}")'
        if name in target_audio:
            return REPLACE_AUDIO
        return m.group(0)

    content = SPR_RE.sub(repl_cb, content)
    content = AUD_RE.sub(repl_cb, content)

    with open(gml_file, 'w', encoding='utf-8') as f:
        f.write(content)

    gml_mod += 1
    total_repl += len(hits)

    # 统计
    spr_hits = [n for n, t in hits if t == 0]
    aud_hits = [n for n, t in hits if t == 1]
    parts = []
    if spr_hits:
        parts.append(f'精灵:{len(spr_hits)}')
    if aud_hits:
        parts.append(f'音乐:{len(aud_hits)}')
    print(f'  [gml]  {gml_file}  ({", ".join(parts)})')

print()
print(f'  修改 {gml_mod} 个 .gml, 共 {total_repl} 处替换')
print()

# ── 第 5 步：生成映射文件 ─────────────────────────────

print('=' * 60)
print('第 5 步：生成 object_sprite_map.json')
print('=' * 60)

with open('datafiles/object_sprite_map.json', 'w', encoding='utf-8') as f:
    json.dump(object_sprite_map, f, indent=2, ensure_ascii=False)
print(f'  {len(object_sprite_map)} 条映射')

# 被移除精灵的详细信息，供后期重建
removed_sprites['_project_root'] = str(PROJECT_ROOT.resolve()) + '\\'
with open('datafiles/removed_sprites.json', 'w', encoding='utf-8') as f:
    json.dump(removed_sprites, f, indent=2, ensure_ascii=False)
print(f'  removed_sprites.json: {len(removed_sprites) - 1} 个精灵 + 项目根路径')
print()

# ── 汇总 ──────────────────────────────────────────────

print('=' * 60)
print('迁移完成！')
print(f'  .yyp:  精灵 -{removed_sprite}  音乐 -{removed_audio}')
print(f'  object: {obj_mod} 个 spriteId 替换')
print(f'  .gml:   {gml_mod} 个文件, {total_repl} 处替换')
print(f'  映射:   {len(object_sprite_map)} 条')
print()
print('用 restore_backup.py 可还原')
print('=' * 60)
