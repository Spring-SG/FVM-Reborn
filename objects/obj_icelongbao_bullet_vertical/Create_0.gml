/// 冰龙包子弹（纵向）：上下飞行，按列判定，两层燃烧
event_inherited();

col = 0;

bullet_collides_obstacle = true;
bullet_collides_brazier  = true;
bullet_collides_bounce   = true;

burnt_fire_level         = 2;
bullet_max_burn          = 2;
bullet_burn_damage_level = 2;

bullet_update        = function() { y += move_speed; };
bullet_out_of_bounds = function() { return (x > 2200 || y > 1200 || x < 0 || y < -200); };
bullet_can_hit_enemy = function(_enemy) { return (_enemy.hp > 0) && can_hit(target_type, _enemy.target_type); };
bullet_obstacle_row_ok = function(_obstacle) { return true; };
bullet_brazier_row_ok  = function(_brazier)  { return (col == _brazier.grid_col); };
bullet_bounce_row_ok   = function(_pudding)  { return (col == _pudding.grid_col); };

bullet_update_sprite = function() {
	if (burnt == 1) sprite_index = spr_xiaolongbao_bullet;
	else if (burnt == 2) sprite_index = spr_fire_bullet;
};

bullet_on_hit_status = function(_enemy) {
	if (_enemy.shield_hp <= 0 && _enemy.ice_timer <= 600 && burnt == 0) _enemy.ice_timer = 600;
};

bullet_on_hit_effect = function() {
	if (burnt == 0) {
		instance_create_depth(x, y, depth, obj_icelongbao_bullet_effect);
	} else if (burnt == 1) {
		instance_create_depth(x, y, depth, obj_xiaolongbao_bullet_effect);
	} else {
		bullet_create_fire_effect();
	}
};