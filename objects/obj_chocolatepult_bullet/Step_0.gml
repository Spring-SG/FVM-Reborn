/// 巧克力投手子弹 Step：通用帧循环 + 溅射点判定
event_inherited();
if (global.is_paused) exit;

if (shape >= 1) splash_ratio = 0.5;

if (target_enemy != noone && instance_exists(target_enemy) && target_enemy.hp > 0) {
	// 已命中主目标：飞到它身后一格再炸
	if (hit_enemy) {
		var _splash_x = target_enemy.x + global.grid_cell_size_x;
		var _splash_y = target_enemy.y;
		if (point_distance(x, y, _splash_x, _splash_y) <= 10 || y >= thrower_y) {
			instance_create_depth(x, y, depth, obj_saladpult_bullet_effect);
			instance_destroy();
		}
	}
} else if (target_enemy != noone && (!instance_exists(target_enemy) || target_enemy.hp <= 0)) {
	// 目标飞行途中死亡：落地炸开
	if (y >= thrower_y) {
		if (sprite_index == spr_stinkytofupult_bullet_poison) {
			var _gp = get_grid_position_from_world(x, y);
			var _poison = instance_create_depth(_gp.x, _gp.y, depth, obj_stinkytofupult_bullet_effect);
			_poison.damage   = round(damage * splash_ratio);
			_poison.grid_row = _gp.row;
		} else {
			var _fx = bullet_create_effect(obj_coffeecup_bullet_effect, spr_chocolatepult_bullet_effect);
			_fx.image_xscale = 1.2;
			_fx.image_yscale = 1.2;
		}
		instance_destroy();
	}
}