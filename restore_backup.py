"""
备份还原脚本
-----------
将所有 .bak 文件还原为原始文件，恢复项目到迁移前的状态。
还原后自动清理所有 .bak 和 object_sprite_map.json。

用法:
    python restore_backup.py
"""

import os
import shutil
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent
os.chdir(PROJECT_ROOT)

print('=' * 60)
print('还原备份文件')
print('=' * 60)

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

for fname in ['object_sprite_map.json', 'removed_sprites.json']:
    f = Path(fname)
    if f.exists():
        f.unlink()
        print(f'  [del]  {fname}')
        removed += 1

print()

if restored == 0:
    print('没有找到任何 .bak 文件，项目可能尚未迁移。')
else:
    print(f'还原完成！共还原 {restored} 个文件，清理 {removed} 个临时文件。')

print('=' * 60)
