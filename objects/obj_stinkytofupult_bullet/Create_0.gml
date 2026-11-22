/// 臭豆腐投手子弹：抛物线飞行，命中后飞向后方溅射（毒液弹走网格特效）
event_inherited();

cvspeed  = 0;
cgravity = 0;

target_enemy = noone;
hitted_enemy = noone;
hit_enemy    = false;
splashed     = false;
shape        = 0;

damage_type  = "throw";
target_type  = "throw";
splash_ratio = 0.35;
image_angle  = 45;

bullet_uses_atk_bonus = true;

bullet_update = function() {
	x += move_speed;
	y -= cvspeed;
	cvspeed -= cgravity;
	image_angle -= 2;
};

bullet_out_of_bounds = function() {
	return (x > 2200 || y > 1200 || x < -200 || y < -200);
};

// 命中即销毁；毒液弹落网格生成毒池，普通弹只是溅射
bullet_on_hit_enemy = function(_enemy) {
	instance_destroy();
	if (sprite_index == spr_stinkytofupult_bullet_poison) {
		var _gp = get_grid_position_from_world(_enemy.x, _enemy.y);
		var _poison = instance_create_depth(_gp.x, _gp.y, depth, obj_stinkytofupult_bullet_effect);
		_poison.damage   = round(damage * splash_ratio);
		_poison.grid_row = _gp.row;
	} else {
		instance_create_depth(x, y, depth, obj_saladpult_bullet_effect);
	}
	hit_enemy    = true;
	hitted_enemy = _enemy.id;
	bullet_pult_redirect(_enemy);
};