"""
精灵 & 音乐迁移脚本（深度版）
--------------------------
精灵帧 PNG → 预合并水平条带 → sprites_join/，运行时 sprite_add 直达，无需 surface 合成。
其余操作与原版一致：删 .yyp、替换 object .yy、替换 .gml。
"""

import json
import re
import os
import shutil
import subprocess
from pathlib import Path
from PIL import Image

PROJECT_ROOT = Path(__file__).parent
os.chdir(PROJECT_ROOT)

# ── 迁移模式互斥检查 ──────────────────────────
_MODE_FILE = PROJECT_ROOT / ".migration_mode"
if _MODE_FILE.exists():
    _prev = _MODE_FILE.read_text(encoding='utf-8').strip()
    if _prev != "depth":
        import ctypes
        ctypes.windll.user32.MessageBoxW(0,
            f"项目已用 {_prev} 模式迁移过，请先运行 lazyloading_restore_backup.py 还原后再试。",
            "迁移模式冲突", 0x30)
        print(f"[错误] 项目已用 {_prev} 模式迁移过，请先 lazyloading_restore_backup.py 还原")
        exit(1)

# ── 配置 ──────────────────────────────────────────────

REPLACE_SPRITE = 'spr_cloud_daytime'   # object .yy spriteId 替换默认值
REPLACE_AUDIO  = 'mus_menu'             # 音乐替换默认值

SPRITE_FOLDERS = [
    'folders/精灵/Enemy/',
    'folders/精灵/Cards/',
    'folders/精灵/Maps/',
    'folders/精灵/UI/Attire/'
]


# 白名单：这些精灵/音乐跳过不处理
SKIP_SPRITES = {
    'spr_town',
    'spr_reday_room',
    'spr_delicious_islands',
    'spr_salad_island_land',
}

SKIP_AUDIO = set()

MAX_STRIP_WIDTH = 16384  # GPU 纹理上限，超出则不迁移（sprite_add 单行条带限制）
SPRITES_JOIN = 'sprites_join'            # 合并后 PNG 输出目录


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


# 清理上次生成的映射文件（removed_sprites.json 保留，多次运行合并）
for _f in ('datafiles/object_sprite_map.json',):
    if os.path.exists(_f):
        os.remove(_f)

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
    seq = info.get('sequence', {}) or {}

    # 按 sequence tracks 的关键帧顺序重排帧列表
    if len(frames_list) > 1:
        tracks = seq.get('tracks', [])
        if tracks:
            kfs = tracks[0].get('keyframes', {}).get('Keyframes', [])
            if kfs and len(kfs) == len(frames_list):
                frames_set = set(frames_list)
                ordered = []
                for kf in sorted(kfs, key=lambda k: k.get('Key', 0)):
                    ch0 = kf.get('Channels', {}).get('0', {})
                    fname = (ch0.get('Id', {}) or {}).get('name', '')
                    if fname in frames_set:
                        ordered.append(fname)
                if len(ordered) == len(frames_list):
                    frames_list = ordered

    # 计算每行最多帧数，超出则拆多段条带
    _w = info.get('width', 0)
    _fc = info.get('frameCount', len(frames_list) or 1)
    _fps = max(1, MAX_STRIP_WIDTH // _w)  # 每段最多帧数
    _strip_count = (_fc + _fps - 1) // _fps  # 需要几段
    _strip_paths = [f'{SPRITES_JOIN}/{name}_{i}.png' for i in range(_strip_count)]


    # 以 .yy 原始数据为底，删掉无用的 meta 键，再覆盖 GML 需要的计算字段
    sprite_data = {k: v for k, v in info.items()
                   if k not in ('$GMSprite', '%Name', 'resourceType', 'resourceVersion', 'name')}
    sprite_data['path']             = dir_path  # 原始帧 PNG 所在目录
    sprite_data['strip_paths']      = _strip_paths
    sprite_data['frames_per_strip'] = _fps
    sprite_data['first_path']       = f'{SPRITES_JOIN}/{name}_first.png'
    sprite_data['frames']     = frames_list
    sprite_data['frameCount'] = info.get('frameCount', len(frames_list) or 1)
    sprite_data['xorigin']    = info['xorigin'] if 'xorigin' in info else seq.get('xorigin', 0)
    sprite_data['yorigin']    = info['yorigin'] if 'yorigin' in info else seq.get('yorigin', 0)
    # fps 取 sequence.playbackSpeed（GMS2 标准位置），避免 or 链吞掉 0 值
    _fps = seq.get('playbackSpeed') if seq.get('playbackSpeed') is not None else 30
    sprite_data['fps']        = _fps
    sprite_data['bbox']       = [
        info.get('bbox_left', 0),
        info.get('bbox_top', 0),
        info.get('bbox_right', 0),
        info.get('bbox_bottom', 0),
    ]
    sprite_data['textureGroup'] = info.get('textureGroupId', {}).get('name', '') \
                                  if isinstance(info.get('textureGroupId'), dict) else ''

    removed_sprites[name] = sprite_data

print(f'  Enemy:  {cat_counts.get("Enemy", 0)} 个')
print(f'  Cards:  {cat_counts.get("Cards", 0)} 个')
print(f'  Maps:   {cat_counts.get("Maps", 0)} 个')
print(f'  白名单: {len(SKIP_SPRITES)} 个')
print(f'  精灵合计: {len(target_sprites)} 个')

# ── 第 1.5 步：生成合并条带 PNG ────────────────────────

print('=' * 60)
print('第 1.5 步：生成 sprites_join 合并条带')
print('=' * 60)

os.makedirs(SPRITES_JOIN, exist_ok=True)

_strips_exist = os.path.isdir(SPRITES_JOIN) and os.listdir(SPRITES_JOIN)
if _strips_exist:
    print(f'  [skip] {SPRITES_JOIN}/ 已存在，跳过条带生成')

strip_count = 0
failed_sprites: set[str] = set()   # 收集生成失败的精灵，后续从 target 和 JSON 中剔除

_strips_src = [] if _strips_exist else removed_sprites.items()
for name, data in _strips_src:
    _dir   = data.get('path', '')
    _fnames = data.get('frames', [])
    _w     = data.get('width', 0)
    _h     = data.get('height', 0)
    _fc    = data.get('frameCount', len(_fnames) or 1)

    if not _fnames or _w <= 0 or _h <= 0:
        print(f'  [skip]  {name}  无帧数据')
        failed_sprites.add(name)
        continue

    # ─ 加载每帧 PNG ─
    frames_img: list[Image.Image] = []
    frame_miss = False
    for fn in _fnames:
        png = Path(f'{_dir}/{fn}.png').resolve()
        if not png.exists():
            # 有时 _dir 是相对路径，试绝对
            png = Path(PROJECT_ROOT) / f'{_dir}/{fn}.png'
        if not png.exists():
            print(f'  [miss]  {name}/{fn}.png')
            frame_miss = True
            break
        frames_img.append(Image.open(png))

    if frame_miss:
        failed_sprites.add(name)
    elif len(frames_img) == _fc:
        # ─ 水平条带（多段）──
        _fps = data['frames_per_strip']
        _strip_count = (_fc + _fps - 1) // _fps
        for _si in range(_strip_count):
            _start = _si * _fps
            _end   = min(_start + _fps, _fc)
            _seg_fc = _end - _start
            strip = Image.new('RGBA', (_w * _seg_fc, _h))
            for j in range(_seg_fc):
                strip.paste(frames_img[_start + j], (j * _w, 0))
            strip.save(data['strip_paths'][_si])
        # ─ 第一帧 ─
        frames_img[0].save(data['first_path'])
        strip_count += 1
    else:
        print(f'  [skip]  {name}  帧数不匹配 ({len(frames_img)} != {_fc})')
        failed_sprites.add(name)
    # 关图
    for img in frames_img:
        img.close()

# 从 target_sprites 和 removed_sprites 中剔除生成失败的精灵
for name in failed_sprites:
    del removed_sprites[name]
    target_sprites.discard(name)

print(f'  生成 {strip_count} 个条带, 失败 {len(failed_sprites)} 个 (剩余 {len(removed_sprites)} 个精灵)')
print()

# ── 音乐：收集目标 & ffmpeg 检测 ────────────────────────

# ffmpeg 检测（① ffmpeg/ffmpeg.exe  ② 项目根 ffmpeg.exe  ③ 系统 PATH  ④ pydub）
_ffmpeg_path = None
_ffmpeg_method = ""
for _check in [PROJECT_ROOT / "ffmpeg" / "ffmpeg.exe", PROJECT_ROOT / "ffmpeg.exe"]:
    if _check.exists():
        _ffmpeg_path = str(_check)
        _ffmpeg_method = f"本地 {_check.relative_to(PROJECT_ROOT)}"
        break
if not _ffmpeg_path:
    _result = subprocess.run(["where", "ffmpeg"], capture_output=True, text=True, shell=True)
    if _result.returncode == 0 and _result.stdout.strip():
        _ffmpeg_path = "ffmpeg"
        _ffmpeg_method = "系统 PATH"
if not _ffmpeg_path:
    try:
        from pydub import AudioSegment as _AudioSegment
        _ffmpeg_path = "pydub"
        _ffmpeg_method = "pydub"
    except ImportError:
        pass

# 收集所有音乐资源（排除白名单）
target_audio: set[str] = set()
for res in yyp_data['resources']:
    rid = res.get('id', {})
    name = rid.get('name', '')
    path = rid.get('path', '')
    if path.startswith('sounds/') and name.startswith('mus_') and name not in SKIP_AUDIO:
        target_audio.add(name)

# 转换为 OGG → backgroundmusic/
_bgm_dir = PROJECT_ROOT / 'backgroundmusic'
_bgm_dir.mkdir(exist_ok=True)
_conv_count = 0
_conv_skip = 0
_conv_fail = 0

if not _ffmpeg_path:
    print(f'[音频] ✗ 未找到 ffmpeg，跳过 OGG 转换（{len(target_audio)} 首音乐将从 .yyp 移除，运行时回退缺省）')
elif not target_audio:
    print('[音频] 所有音乐在白名单中，无需转换')
else:
    print(f'[音频] 使用 {_ffmpeg_method} 转换 {len(target_audio)} 首 → backgroundmusic/ ...')
    for _name in sorted(target_audio):
        _src_dir = PROJECT_ROOT / 'sounds' / _name
        _src_path = None
        _src_fmt = None
        for _ext in ('.mp3', '.MP3', '.wav', '.WAV', '.ogg', '.OGG'):
            _c = _src_dir / f'{_name}{_ext}'
            if _c.exists():
                _src_path = _c
                _src_fmt = _ext.lower()
                break
        if not _src_path:
            _conv_skip += 1
            continue
        _dst = _bgm_dir / f'{_name}.ogg'
        if _dst.exists():
            _conv_skip += 1
            continue
        try:
            if _ffmpeg_path == "pydub":
                from pydub import AudioSegment
                if _src_fmt == '.mp3':
                    AudioSegment.from_mp3(_src_path).export(_dst, format='ogg')
                elif _src_fmt == '.wav':
                    AudioSegment.from_wav(_src_path).export(_dst, format='ogg')
                else:
                    shutil.copy2(_src_path, _dst)
            else:
                if _src_fmt == '.ogg':
                    shutil.copy2(_src_path, _dst)
                else:
                    subprocess.run([_ffmpeg_path, '-y', '-i', str(_src_path),
                                    '-c:a', 'libvorbis', '-q:a', '4', str(_dst)],
                                   capture_output=True, check=True)
            _conv_count += 1
        except Exception as _e:
            print(f'  [FAIL]  {_name}: {_e}')
            _conv_fail += 1
            target_audio.discard(_name)  # 转换失败不迁移

    print(f'  转换: {_conv_count}  跳过: {_conv_skip}  失败: {_conv_fail}')
    print(f'  输出: backgroundmusic/ ({len(list(_bgm_dir.glob("*.ogg")))} 个 OGG)')

print(f'  待迁移音乐: {len(target_audio)} 首')
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

object_sprite_map: dict[str, list[str]] = {}
yy_sprite_map: dict[str, str] = {}  # 只记录第 3 步实际替换过的 object → 原始精灵
obj_mod = 0
obj_skip = 0

for yy_file in sorted(Path('objects').glob('**/*.yy')):
    data = parse_gm_json(yy_file)

    if data.get('resourceType') != 'GMObject':
        continue

    oname = data.get('name', '')

    sid = data.get('spriteId')
    if not sid:
        obj_skip += 1
        continue

    sname = sid.get('name', '')
    if sname not in target_sprites:
        obj_skip += 1
        continue

    # 记录映射
    if oname not in object_sprite_map:
        object_sprite_map[oname] = []
    object_sprite_map[oname].append(sname)
    yy_sprite_map[oname] = sname  # 记录 .yy 原始精灵，Step 4.5 用

    # 替换 spriteId
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
            return f'get_load_audio("{name}")'
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

    # 收集对象→精灵引用（objects/ 下的 .gml 归属到对应对象）
    if spr_hits:
        _gml_str = str(gml_file).replace('\\', '/')
        if _gml_str.startswith('objects/'):
            _obj_name = gml_file.parent.name
            if _obj_name not in object_sprite_map:
                object_sprite_map[_obj_name] = []
            for _s in spr_hits:
                if _s not in object_sprite_map[_obj_name]:
                    object_sprite_map[_obj_name].append(_s)

    parts = []
    if spr_hits:
        parts.append(f'精灵:{len(spr_hits)}')
    if aud_hits:
        parts.append(f'音乐:{len(aud_hits)}')
    print(f'  [gml]  {gml_file}  ({", ".join(parts)})')

print()
print(f'  修改 {gml_mod} 个 .gml, 共 {total_repl} 处替换')
print()

# ── 第 4.5 步：确保被迁移 object 的 Create 事件设置 pid sprite_index ──
# .yy spriteId 被替换为 spr_cloud_daytime 后，如果 sprite_index 从未被设为 pid
#（≥100000），draw_self hook 不会拦截，永久渲染云朵。
# 这里无条件在 Create_0.gml 首行注入赋值，确保 sprite_index 始终是 pid。

print('=' * 60)
print('第 4.5 步：Create_0.gml 首行注入 sprite_index')
print('=' * 60)

create_inject = 0

for oname, original_sprite in sorted(yy_sprite_map.items()):
    create_file = Path(f'objects/{oname}/Create_0.gml')
    if not create_file.exists():
        continue

    backup_if_needed(create_file)
    inject_line = f'sprite_index = get_load_sprite("{original_sprite}");  //转化额外添加保证触发\n'
    with open(create_file, 'r', encoding='utf-8') as f:
        content = f.read()
    with open(create_file, 'w', encoding='utf-8') as f:
        f.write(inject_line + content)

    create_inject += 1
    print(f'  [create]  {oname}  sprite_index = get_load_sprite("{original_sprite}")')

print()
print(f'  注入 {create_inject} 个')
print()

# ── 第 5 步：生成映射文件 ─────────────────────────────

print('=' * 60)
print('第 5 步：生成 object_sprite_map.json')
print('=' * 60)

with open('datafiles/object_sprite_map.json', 'w', encoding='utf-8') as f:
    json.dump(object_sprite_map, f, indent=2, ensure_ascii=False)
# 统计精灵引用总数
_total_refs = sum(len(v) for v in object_sprite_map.values())
print(f'  {len(object_sprite_map)} 个对象, {_total_refs} 条精灵引用')
print()

# ── 第 5.5 步：构建 object 依赖图（谁创建谁）──

print('=' * 60)
print('第 5.5 步：构建 object_deps.json（递归精灵依赖）')
print('=' * 60)

INST_RE = re.compile(r'instance_create_depth\s*\([^,]*,[^,]*,[^,]*,\s*(obj_\w+)')
object_creates: dict[str, set[str]] = {}

for gml_file in sorted(Path('objects').glob('**/*.gml')):
    with open(gml_file, 'r', encoding='utf-8') as f:
        content = f.read()
    for m in INST_RE.finditer(content):
        target = m.group(1)
        owner = gml_file.parent.name
        if owner not in object_creates:
            object_creates[owner] = set()
        object_creates[owner].add(target)

# 递归展开：从 object_sprite_map 出发，合并所有被创建 object 的精灵
object_deps: dict[str, list[str]] = {}

def _collect_sprites(oname: str, visited: set[str]) -> set[str]:
    if oname in visited:
        return set()
    visited.add(oname)
    sprites = set(object_sprite_map.get(oname, []))
    for child in object_creates.get(oname, []):
        sprites |= _collect_sprites(child, visited)
    return sprites

for oname in sorted(set(list(object_sprite_map.keys()) + list(object_creates.keys()))):
    object_deps[oname] = sorted(_collect_sprites(oname, set()))

with open('datafiles/object_deps.json', 'w', encoding='utf-8') as f:
    json.dump(object_deps, f, indent=2, ensure_ascii=False)
_dep_objs = len(object_deps)
_dep_refs = sum(len(v) for v in object_deps.values())
print(f'  {_dep_objs} 个对象, {_dep_refs} 条精灵引用（含递归）')
print()

# 被移除精灵的详细信息，供后期重建（合并已有数据，支持多次运行）
_rm_path = Path('datafiles/removed_sprites.json')
if _rm_path.exists():
    _existing = json.loads(clean_trailing_commas(_rm_path.read_text(encoding='utf-8')))
    _existing.pop('_project_root', None)
    _existing.update(removed_sprites)
    removed_sprites = _existing
removed_sprites['_project_root'] = str(PROJECT_ROOT.resolve()) + '\\'
with open(_rm_path, 'w', encoding='utf-8') as f:
    json.dump(removed_sprites, f, indent=2, ensure_ascii=False)
print(f'  removed_sprites.json: {len(removed_sprites) - 1} 个精灵 + 项目根路径')
print()

# 生成音频预加载列表，写入 removed_sprites.json
_audio_list = []
_snds = PROJECT_ROOT / 'sounds'
if _snds.exists():
    for _d in sorted(_snds.iterdir()):
        if _d.is_dir() and _d.name.startswith('mus_'):
            _audio_list.append(_d.name)
removed_sprites['_music_list'] = _audio_list
print(f'  _music_list: {len(_audio_list)} 首音乐')
print()

# 写入迁移模式标记
_MODE_FILE = PROJECT_ROOT / ".migration_mode"
_MODE_FILE.write_text("depth", encoding="utf-8")

# ── 汇总 ──────────────────────────────────────────────

print('=' * 60)
print('迁移完成！')
print(f'  .yyp:  精灵 -{removed_sprite}  音乐 -{removed_audio}')
print(f'  object: {obj_mod} 个 spriteId 替换')
print(f'  .gml:   {gml_mod} 个文件, {total_repl} 处替换')
print(f'  映射:   {len(object_sprite_map)} 个对象, {sum(len(v) for v in object_sprite_map.values())} 条精灵引用')
print()
print('用 lazyloading_restore_backup.py 可还原')
print('=' * 60)
