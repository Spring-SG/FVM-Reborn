if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}

var _x = x;
var _y = y;
var _range = 320
var _row_range = 2

timer ++

if timer mod 30 == 5{
	with (obj_enemy_parent) {
		if (abs(x - other.x) < _range && abs(grid_row-other.grid_row) <= _row_range){
			if ice_timer < 600{
				ice_timer = 600
			}
		}
	}
}