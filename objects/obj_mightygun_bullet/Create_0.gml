/// 强力枪子弹：标准四碰撞直射弹
event_inherited();

bullet_collides_obstacle = true;
bullet_collides_brazier  = true;
bullet_collides_bounce   = true;

bullet_on_hit_effect = function() {
	if (burnt == 0) {
		instance_create_depth(x, y, depth, obj_xiaolongbao_bullet_effect);
	} else {
		bullet_create_fire_effect();
	}
};