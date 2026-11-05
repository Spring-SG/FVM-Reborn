/// 烤蜥蜴投手子弹：抛物线飞行，命中/落地炸开并溅射
event_inherited();

cvspeed  = 0;
cgravity = 0;

target_enemy = noone;
hitted_enemy = noone;
hit_enemy    = false;
splashed     = false;
shape        = 0;

damage_type = "throw";
target_type = "throw";
image_angle = -45;

bullet_uses_atk_bonus = true;

bullet_update = function() {
	x += move_speed;
	y -= cvspeed;
	cvspeed -= cgravity;
	image_angle -= 5;
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

bullet_play_hit_sound = function(_enemy) {
	global.audio.play(snd_egg_bullet, 0, 0);
};

bullet_on_hit_enemy = function(_enemy) {
	hit_enemy    = true;
	hitted_enemy = _enemy.id;
	bullet_create_effect(obj_coke_bomb_explode, spr_roast_lizard_pult_bullet_effect);
	instance_destroy();
};