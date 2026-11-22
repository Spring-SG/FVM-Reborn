/// 咖啡杯子弹：有射程限制（走满 4 格后淡出）
event_inherited();

image_xscale = 1.5;
image_yscale = 1.5;

state      = 1;
state_timer = 0;
shape      = 0;
col        = 0;
start_col  = 0;
disabled   = false;

bullet_collides_obstacle = true;

bullet_can_hit_enemy = function(_enemy) {
	return (!disabled)
		&& (_enemy.hp > 0)
		&& (row == _enemy.grid_row)
		&& can_hit(target_type, _enemy.target_type);
};

bullet_on_hit_effect = function() {
	instance_create_depth(x, y, depth, obj_coffeecup_bullet_effect);
};