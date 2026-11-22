/// 冰龙包系子弹：火盆可叠两层燃烧，命中附加冰冻
event_inherited();

bullet_collides_obstacle = true;
bullet_collides_brazier  = true;
bullet_collides_bounce   = true;

// 两层燃烧：满两层才结算加成、命中播燃烧音效
burnt_fire_level         = 2;
bullet_max_burn          = 2;
bullet_burn_damage_level = 2;

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