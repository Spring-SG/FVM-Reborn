/// 炭烤海星子弹：带纵向分速度，无火盆点燃逻辑
event_inherited();

image_xscale = 1.5;
image_yscale = 1.5;
y_move_speed = 0;
col = 0;
b_type = 0;   // 0 = 任意行都命中，1 = 仅同行

bullet_collides_obstacle = true;
bullet_collides_bounce   = true;

bullet_update        = function() { x += move_speed; y += y_move_speed; };
bullet_out_of_bounds = function() { return (x > 2200 || y > 1200 || x < 0 || y < -200); };
bullet_bounce_row_ok   = function(_pudding)  { return true; };
bullet_obstacle_row_ok = function(_obstacle) { return true; };

bullet_on_bounce = function() { y_move_speed *= -1; };

bullet_can_hit_enemy = function(_enemy) {
	return (_enemy.hp > 0)
		&& can_hit(target_type, _enemy.target_type)
		&& (b_type == 0 || (b_type == 1 && row == _enemy.grid_row));
};

bullet_on_hit_effect = function() {
	if (burnt != 0) bullet_create_fire_effect();
};