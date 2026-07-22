"""
备份还原脚本
-----------
将所有 .bak 文件还原为原始文件，恢复项目到迁移前的状态。
还原后自动清理所有 .bak 和 object_sprite_map.json。

用法:
    python lazyloading_restore_backup.py [--keep-join]

参数:
    --keep-join  保留 sprites_join/ 和 backgroundmusic/ 目录
"""

import os
import shutil
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent
os.chdir(PROJECT_ROOT)

import sys

keep_join = '--keep-join' in sys.argv

print('=' * 60)
print('还原备份文件')
print('=' * 60)

if keep_join:
    print('  [info] 保留 sprites_join/ 目录')
print()

restored = 0
removed = 0

# ── 1. 还原 .yyp ─────────────────────────────────────

yyp_bak = Path('FVM-reborn.yyp.bak')
if yyp_bak.exists():
    target = Path('FVM-reborn.yyp')
    shutil.copy2(yyp_bak, target)
    yyp_bak.unlink()
    print(f'  [yyp]  {target.name}')
    restored += 1
    removed += 1
else:
    print(f'  [ - ]  未找到 {yyp_bak.name}')

# ── 2. 还原所有 object .yy ────────────────────────────

for bak_file in sorted(Path('objects').glob('**/*.yy.bak')):
    original = Path(str(bak_file)[:-4])
    shutil.copy2(bak_file, original)
    bak_file.unlink()
    print(f'  [obj]  {original.name}')
    restored += 1
    removed += 1

# ── 3. 还原所有 .gml ─────────────────────────────────

for bak_file in sorted(Path('scripts').glob('**/*.gml.bak')):
    original = Path(str(bak_file)[:-4])
    shutil.copy2(bak_file, original)
    bak_file.unlink()
    print(f'  [gml]  {original}')
    restored += 1
    removed += 1

for bak_file in sorted(Path('objects').glob('**/*.gml.bak')):
    original = Path(str(bak_file)[:-4])
    shutil.copy2(bak_file, original)
    bak_file.unlink()
    print(f'  [gml]  {original}')
    restored += 1
    removed += 1

# ── 4. 清理映射文件 ──────────────────────────────────

for fname in ['datafiles/object_deps.json','datafiles/object_sprite_map.json', 'datafiles/removed_sprites.json']:
    f = Path(fname)
    if f.exists():
        f.unlink()
        print(f'  [del]  {fname}')
        removed += 1

# ── 5. 清理 sprites_join ──────────────────────────────

if not keep_join:
    for _dirname in ["sprites_join", "backgroundmusic"]:
        _dir = Path(_dirname)
        if _dir.exists() and _dir.is_dir():
            _count = 0
            for _f in _dir.iterdir():
                _f.unlink()
                _count += 1
            _dir.rmdir()
            removed += _count
            print(f"  [del]  {_dirname}/  ({_count} files)")
else:
    print("  [skip] sprites_join/ kept")
    print("  [skip] backgroundmusic/ kept")

print()

# 清理迁移模式标记
_mode_marker = Path('.migration_mode')
if _mode_marker.exists():
    _mode_marker.unlink()
    print('  [del]  .migration_mode')

if restored == 0:
    print('没有找到任何 .bak 文件，项目可能尚未迁移。')
else:
    print(f'还原完成！共还原 {restored} 个文件，清理 {removed} 个临时文件。')

print('=' * 60)
