/// 沙拉投手子弹：抛物线飞行，命中后继续飞向后方溅射
event_inherited();

image_xscale = 1.4;
image_yscale = 1.4;

cvspeed  = 0;
cgravity = 0;

target_enemy = noone;
hitted_enemy = noone;
hit_enemy    = false;
splashed     = false;
shape        = 0;

damage_type = "throw";
target_type = "throw";
image_angle = 45;

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

bullet_can_hit_enemy = function(_enemy) {
	return (!hit_enemy)
		&& (_enemy.hp > 0)
		&& (row == _enemy.grid_row)
		&& can_hit(target_type, _enemy.target_type);
};

// 命中后不销毁，先炸一次再飞向后方溅射点
bullet_on_hit_enemy = function(_enemy) {
	instance_create_depth(x, y, depth, obj_saladpult_bullet_effect);
	hit_enemy    = true;
	hitted_enemy = _enemy.id;
	bullet_pult_redirect(_enemy);
};