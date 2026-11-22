/// 小笼包子弹：普通直射弹，燃烧后换火焰弹
event_inherited();

bullet_collides_obstacle = true;
bullet_collides_brazier  = true;
bullet_collides_bounce   = true;

bullet_on_hit_effect = function() {
	if (burnt == 0) {
		var _fx = bullet_create_effect(obj_xiaolongbao_bullet_effect);
		if (sprite_index == spr_gatling_popcorn_bullet)   _fx.sprite_index = spr_gatling_popcorn_bullet_effect;
		if (sprite_index == spr_gatling_popcorn_bullet_1) _fx.sprite_index = spr_gatling_popcorn_bullet_effect_1;
		if (sprite_index == spr_gatling_popcorn_bullet_2) _fx.sprite_index = spr_gatling_popcorn_bullet_effect_2;
	} else {
		bullet_create_fire_effect();
	}
};