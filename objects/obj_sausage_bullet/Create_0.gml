/// 香肠子弹：对空弹，飞到 target_y 高度后平飞
event_inherited();

target_type = "air";
target_y = 0;

bullet_collides_obstacle = true;

bullet_update = function() {
	x += move_speed;
	if (y > target_y) y -= 5;
};

bullet_on_hit_effect = function() {
	bullet_create_effect(obj_xiaolongbao_bullet_effect, spr_sausage_bullet_effect);
};