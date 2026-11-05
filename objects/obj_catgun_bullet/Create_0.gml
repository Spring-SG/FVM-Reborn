/// 猫枪子弹：不造成伤害，只把老鼠吓到相邻行
event_inherited();

image_xscale = 1.6;
image_yscale = 1.6;
bullet_anim_manual = true;
target_row = 0;

bullet_collides_obstacle = true;

// 只吓退、不造成伤害：覆盖父对象的伤害结算
bullet_damage_enemy = function(_enemy) {};

bullet_on_hit_enemy = function(_enemy) {
	with (_enemy) {
		scare_timer = 30;
		left_move_flashs = 30;
		if (grid_row == 0) {
			if (global.row_feature[1] == global.row_feature[0]) {
				y_move = global.grid_cell_size_y / left_move_flashs;
				grid_row += 1;
			}
		} else if (grid_row == global.grid_rows - 1) {
			if (global.row_feature[global.grid_rows - 2] == global.row_feature[global.grid_rows - 1]) {
				y_move = -global.grid_cell_size_y / left_move_flashs;
				grid_row -= 1;
			}
		} else {
			var _im = irandom_range(1, 100);
			var _up_water   = global.row_feature[grid_row - 1] != global.row_feature[grid_row];
			var _down_water = global.row_feature[grid_row + 1] != global.row_feature[grid_row];
			if (_down_water) _im = 25;
			if (_up_water)   _im = 75;
			if (!(_up_water && _down_water)) {
				if (_im > 50) {
					y_move = global.grid_cell_size_y / left_move_flashs;
					grid_row += 1;
				} else {
					y_move = -global.grid_cell_size_y / left_move_flashs;
					grid_row -= 1;
				}
			}
		}
	}
	instance_destroy();
};