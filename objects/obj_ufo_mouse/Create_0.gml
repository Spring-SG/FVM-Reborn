// Inherit the parent event
event_inherited();

mouse_id = "ufo_mouse"
state = BOSS_STATE.IDLE
hp = 120000
maxhp = 120000
wait_time = 240
immune_to_ash = true
sprite_index = spr_ufo_mouse_idle
is_boss = true

// 飞碟鼠悬停在空中：只有对空/追踪/旋转类卡片的子弹能打到它
target_type = "air"

image_alpha = 0
image_xscale = 1.8
image_yscale = 1.8
appear = false		// 是否已经确定过入场位置
first_appear = true	// 入场那次出现动画只播一次

// ===== 技能轮转 =====
skill_count = 0		// 下一个要释放的技能（0=技能1 1=技能2 2=技能3，循环）
skill_phase = 0		// 本次正在执行的技能
skill_step = 0		// 0=尚未开始 1=技能已开始 2/3=技能中途的第 N 次位移

// ===== 位移 =====
dest_x = x
dest_y = y
dest_ready = false	// true=技能已经指定好落点；false=由 DISAPPEAR 按技能自行定位
positioning = false	// 本次飞行是不是"技能开始前的定位飞行"（决定落地时要不要翻转贴图）
move_time = 120		// 本次飞行用多少帧走完
move_dx = 0
move_dy = 0

// ===== 技能1：连跳两格，各吸走 3*3 卡片 =====
cell_col = 0
cell_row = 0

// ===== 技能2：喷火 =====
burn_row = 3		// 喷火所在行（0-based 第 4 行）
flame_col_1 = 0
flame_col_2 = 0
flame_start = 105	// 火焰开始喷出的 tick（对应精灵第 21 帧）
flame_step = 4		// 每几 tick 往下多一行

/// @function get_dest(_col, _row)
/// @description 取"本体正对 (_col,_row) 这一格"的世界坐标。
///              注意：get_world_position_from_grid 给的是格子中心，惯例再减 90，
///              而 -90 差不多是一格，会让本体实际落在设置列左侧一列；
///              所以这里统一把列 +1 补偿回来 —— 传进来的 _col 就是本体真正落到的列。
get_dest = function(_col, _row) {
	var _pos = get_world_position_from_grid(_col + 1, _row);
	return { x: _pos.x - 90, y: _pos.y + 30 };
};

/// @function get_skill_state(_phase)
/// @description 技能下标 -> 对应的状态机状态
get_skill_state = function(_phase) {
	switch (_phase) {
		case 0: return BOSS_STATE.SKILL1;
		case 1: return BOSS_STATE.SKILL2;
		default: return BOSS_STATE.SKILL3;
	}
};

/// @function destroy_3x3(_col, _row)
/// @description 摧毁以 (_col,_row) 为中心的 3*3 范围内的卡片
destroy_3x3 = function(_col, _row) {
	with (obj_card_parent) {
		if (abs(grid_col - _col) <= 1 && abs(grid_row - _row) <= 1
			&& plant_id != "player" && plant_type != "coffee" && plant_type != "lilypad"
			&& !invincible && plant_id != "cotton_candy") {
			if (hp >= max_hp) {
				obj_task_manager.card_loss++;
			}
			instance_destroy();
		}
	}
	var _pos = get_world_position_from_grid(_col, _row);
	//instance_create_depth(_pos.x, _pos.y, -800, obj_coke_bomb_explode);
};

/// @function spawn_flame_cell(_col, _row)
/// @description 点亮一格：燃烧特效 + obj_lava，30 秒后一起消失。
///              特效深度对齐该格 lilypad 层，卡片会盖在火上面
spawn_flame_cell = function(_col, _row) {
	var _pos = get_world_position_from_grid(_col, _row);
	var _depth = calculate_plant_depth(_col, _row, "lilypad");
	var _inst = instance_create_depth(_pos.x, _pos.y + 15, _depth, obj_ufo_mouse_burn);
	_inst.col = _col;
	_inst.row = _row;
};

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}