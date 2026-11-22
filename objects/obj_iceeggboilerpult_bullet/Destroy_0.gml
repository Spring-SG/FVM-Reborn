/// 冰煮蛋投手子弹 Destroy：范围溅射 + 冰冻
event_inherited();

var _x = x;
var _y = y;
var _row_range = 1;
if (instance_exists(hitted_enemy)) {
	_x = hitted_enemy.x;
	_y = hitted_enemy.y;
}
var _range  = 200;
var _splash = 0.25;
if (shape >= 2) {
	_row_range = 2;
	_range = 350;
}

with (obj_enemy_parent) {
	if (hp > 0 && point_distance(x, y, _x, _y) < _range
		&& grid_row <= other.row + _row_range && grid_row >= other.row - _row_range
		&& id != other.hitted_enemy && can_hit(other.target_type, target_type)) {
		damage_amount = other.damage * _splash;
		damage_type   = other.damage_type;
		if (ice_timer < 600) ice_timer = 600;
		event_user(0);
	}
}
global.audio.play(snd_egg_bullet, 0, 0);