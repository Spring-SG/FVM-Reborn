if global.is_paused{
	exit
}
var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = 0
	sprite_set_offset(sprite_index,86,120)
	image_angle -= 8
	x += x_speed
	y += y_speed
	if timer >= 120{
		timer = 0
		state = "anim"
	}
}
else if state == "anim"{
	image_angle = 0
	image_index = floor(timer/5) mod 11 + 1
	sprite_set_offset(sprite_index,69,201)
	if timer >= 11*5-1{
		timer = 0
		state = "idle"
	}
}
else if state == "idle"{
	image_index = floor(timer/5) mod 8 + 12
	with obj_flame{
		is_collected = false
		is_capture = true
		speed = 8
		if global.is_paused{
			speed = 0
		}
		direction = point_direction(x,y,other.x+20,other.y-250)
		if (abs(x - other.x-20)<=10 && abs(y - other.y+250)<=10){
			instance_destroy()
		}
	}
}
else if state == "death"{
	image_index = 0
	image_alpha -= 0.1
}

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}

if image_alpha <= 0 && hp <= 0{
	instance_destroy()
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (8 * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;