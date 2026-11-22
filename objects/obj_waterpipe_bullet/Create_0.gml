/// 水管炮子弹：水平直射，可向目标行靠拢
event_inherited();

image_xscale = 1.6;
image_yscale = 1.6;

// 目标行，-1 = 不做上下行插值
target_row = -1;

bullet_collides_obstacle = true;
bullet_collides_brazier  = true;
bullet_collides_bounce   = true;

// 水平飞行 + 向目标行平滑靠拢
bullet_update = function() {
	x += move_speed;
	if (target_row != -1) {
		var _ty = global.grid_offset_y + global.grid_cell_size_y * target_row;
		y = lerp(y, _ty, 0.15);
		if (abs(y - _ty) < 30) row = target_row;
	}
};

bullet_on_hit_effect = function() {
	if (burnt == 0) {
		instance_create_depth(x, y, depth, obj_waterpipe_bullet_effect);
	} else {
		bullet_create_fire_effect();
	}
};