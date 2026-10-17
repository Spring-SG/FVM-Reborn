/// obj_ladder Step
/// 每帧逻辑：
///   1) 已绑定的宿主被铲/被吃/被炸 → 梯子立刻自毁（必须先判，避免下面反查把引用冲掉）
///   2) 还没绑定时才反查宿主；若长时间找不到宿主（无效梯子）也自毁
/// 注意：位置完全沿用放梯瞬间的坐标（原版表现），不做任何贴合移动。
if (global.is_paused) exit;

// ---- 1) 已绑定的宿主没了就立刻自毁 ----
if (host_plant != noone) {
	if (!instance_exists(host_plant) || host_plant.hp <= 0) {
		instance_destroy();
		exit;
	}
	host_plant.have_loder = true;
	spawn_row = host_plant.grid_row
	spawn_col = host_plant.grid_col
	x = host_plant.x+20 //梯子跟着卡片移动
	y = host_plant.y+10
			
}

// ---- 2) 还没绑定时才反查宿主（只查一次；太久找不到说明是无效梯子）----
if (host_plant == noone) {
	host_search_timer++;
	if (host_search_timer >= 120) {
		instance_destroy();
		exit;
	}
	var _gp = get_grid_position_from_world(x, y);
	// 优先用**放置者所在格**（spawn_row/col）：梯子自己画在 y-37，靠行下沿会算成上一行 → 会绑错植物
	var _row = (spawn_row >= 0) ? spawn_row : _gp.row;
	var _col = (spawn_col >= 0) ? spawn_col : _gp.col;
	var _best = noone;
	var _best_dist = 999999;
	// 同一行、且列在自身格 ±1 范围内的植物中，取离梯子最近的一株
	with (obj_card_parent) {
		if (grid_row == _row) {
			if (abs(grid_col - _col) <= 1) {
				var _d = abs(x - other.x);
				// _best / _best_dist 是 var（函数级作用域），跨 with 共享，必须用裸名访问
				if (_d < _best_dist) {
					_best = id;
					_best_dist = _d;
				}
			}
		}
	}
	host_plant = _best;
}