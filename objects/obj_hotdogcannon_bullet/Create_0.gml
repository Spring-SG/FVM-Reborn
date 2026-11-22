/// 热狗炮子弹：对空弹，飞到 target_y 高度后平飞并附加冰冻
event_inherited();

target_type = "air";
target_y = 0;

bullet_collides_obstacle = true;

bullet_update = function() {
	x += move_speed;
	if (y > target_y) y -= 5;
};

bullet_on_hit_status = function(_enemy) {
	if (_enemy.ice_timer < 600) _enemy.ice_timer = 600;
};

bullet_on_hit_effect = function() {
	bullet_create_effect(obj_xiaolongbao_bullet_effect, spr_hotdogcannon_bullet_effect);
};

// 撞障碍物用的是香肠弹碎片
bullet_on_hit_obstacle = function(_obstacle) {
	bullet_create_effect(obj_xiaolongbao_bullet_effect, spr_hotdogcannon_bullet_effect);
	instance_destroy();
};