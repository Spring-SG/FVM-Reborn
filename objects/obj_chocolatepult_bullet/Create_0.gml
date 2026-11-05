/// 巧克力投手子弹：抛物线飞行，命中后飞向主目标后方溅射
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

bullet_on_hit_enemy = function(_enemy) {
	if (sprite_index == spr_chocolatepult_bullet_large) {
		// 巨型巧克力：不炸开，改为眩晕
		if (shape >= 1) {
			if (_enemy.stun_timer < 240) _enemy.stun_timer = 240;
		} else {
			if (_enemy.stun_timer < 420) _enemy.stun_timer = 420;
		}
		_enemy.stun_sprite = spr_mouse_stick;
	} else {
		var _fx = bullet_create_effect(obj_coffeecup_bullet_effect, spr_chocolatepult_bullet_effect);
		_fx.image_xscale = 1.2;
		_fx.image_yscale = 1.2;
	}
	hit_enemy    = true;
	hitted_enemy = _enemy.id;
	bullet_pult_redirect(_enemy);
	instance_destroy();
};