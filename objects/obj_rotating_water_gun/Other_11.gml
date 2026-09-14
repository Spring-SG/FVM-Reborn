var _x = x;
var _y = y;
var _range = 320
var _row_range = 2

with (obj_enemy_parent) {
	if (abs(x - other.x) < _range && abs(grid_row-other.grid_row) <= _row_range){
		hp -= other.atk;
		event_user(0)
	}
}

var inst = instance_create_depth(x,y+45,-800,obj_coke_bomb_explode)
inst.sprite_index = spr_rotating_water_gun_bullet