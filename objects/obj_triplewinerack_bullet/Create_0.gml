/// 三层酒架子弹：水平直射 + 手动逐帧动画
event_inherited();

bullet_anim_manual = true;   // 按 timer 手动推帧
target_row = 0;

bullet_collides_obstacle = true;
bullet_collides_brazier  = true;
bullet_collides_bounce   = true;

bullet_update = function() {
	x += move_speed;
	var _ty = global.grid_offset_y + global.grid_cell_size_y * target_row;
	y = lerp(y, _ty, 0.15);
	if (abs(y - _ty) < 30) row = target_row;
};

bullet_on_hit_effect = function() {
	if (burnt == 0) {
		var _fx = bullet_create_effect(obj_coffeecup_bullet_effect, spr_triplewinerack_bullet_effect);
		if (sprite_index == spr_wine_rack_sagittarius_bullet)   _fx.sprite_index = spr_wine_rack_sagittarius_bullet_effect;
		if (sprite_index == spr_wine_rack_sagittarius_bullet_1) _fx.sprite_index = spr_wine_rack_sagittarius_bullet_effect_1;
	} else {
		bullet_create_fire_effect();
	}
};