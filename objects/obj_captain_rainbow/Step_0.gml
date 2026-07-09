if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}

if state == "appear"{
	image_index = floor(timer/5) mod 11
	if timer >= 11*5 - 1{
		timer = 0
		state = "idle"
	}
}
else if state == "idle"{
	image_index = floor(timer/5) mod 37 + 11
	if timer >= 300{
		timer = 0
		instance_create_depth(grid_pos.x+10,grid_pos.y+38,depth,obj_soldier_mouse)
		state = "death"
	}
}
else if state == "death"{
	image_index = floor(timer/5) mod 12 + 48
	if timer >= 12*5 - 1{
		instance_destroy()
	}
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (9 * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;