var _x = x;
var _y = y;
var _range = 250
with (obj_enemy_parent) {
		
	if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-1&&grid_row <= other.grid_row+1) {
		hp -= other.bleed_damage
		event_user(0)
	}
}