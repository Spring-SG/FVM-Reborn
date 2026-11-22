/// 生煎包投手子弹：本体不直接造成伤害，命中/落地只在网格上留溅射源
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
splash_ratio = 1;
image_angle  = -45;

// 生煎包不受水果塔加成
bullet_uses_atk_bonus = false;

bullet_update = function() {
	x += move_speed;
	y -= cvspeed;
	cvspeed -= cgravity;
	image_angle -= 2;
};

bullet_out_of_bounds = function() {
	return (x > 2200 || y > 1200 || x < -200 || y < -200);
};

// 生成网格溅射源，伤害在溅射对象里结算
bullet_pan_splash = function(_px, _py, _grid_row) {
	var _inst = instance_create_depth(_px, _py, 0, obj_panfriedbun_bullet_effect);
	_inst.damage   = round(damage * splash_ratio);
	_inst.grid_row = _grid_row;
	_inst.shape    = shape;
	if (shape >= 1) _inst.sprite_index = spr_panfriedbun_bullet_effect_2;
};

// 本体不结算伤害，避免与溅射重复
bullet_damage_enemy = function(_enemy) {};

bullet_on_hit_enemy = function(_enemy) {
	var _gp = get_grid_position_from_world(_enemy.x, _enemy.y);
	bullet_pan_splash(_gp.x, _gp.y, _gp.row);
	instance_destroy();
};
