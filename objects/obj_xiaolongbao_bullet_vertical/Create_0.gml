/// 小笼包子弹（纵向）：上下飞行，按列判定
event_inherited();

col = 0;

bullet_collides_obstacle = true;
bullet_collides_brazier  = true;
bullet_collides_bounce   = true;

bullet_update       = function() { y += move_speed; };
bullet_out_of_bounds = function() { return (x > 2200 || y > 1200 || x < 0 || y < -200); };
bullet_can_hit_enemy = function(_enemy) { return (_enemy.hp > 0) && can_hit(target_type, _enemy.target_type); };
bullet_obstacle_row_ok = function(_obstacle) { return true; };
bullet_brazier_row_ok  = function(_brazier)  { return (col == _brazier.grid_col); };
bullet_bounce_row_ok   = function(_pudding)  { return (col == _pudding.grid_col); };

bullet_on_hit_effect = function() {
	if (burnt == 0) {
		instance_create_depth(x, y, depth, obj_xiaolongbao_bullet_effect);
	} else {
		bullet_create_fire_effect();
	}
};