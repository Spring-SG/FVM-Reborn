/// 仙人掌刺身子弹：水平直射 + 手动逐帧动画
event_inherited();

bullet_anim_manual = true;
target_row = 0;

bullet_collides_brazier = true;
bullet_collides_bounce  = true;

bullet_update = function() {
	x += move_speed;
	var _ty = global.grid_offset_y + global.grid_cell_size_y * target_row;
	y = lerp(y, _ty, 0.15);
	if (abs(y - _ty) < 30) row = target_row;
};

bullet_on_hit_effect = function() {
	if (burnt == 0) {
		bullet_create_effect(obj_coke_bomb_explode, spr_cactus_sashimi_bullet_effect);
	} else {
		bullet_create_fire_effect();
	}
};