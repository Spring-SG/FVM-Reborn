if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = floor(timer/5) mod 6
	image_alpha += 0.1
	image_xscale += 0.09
	image_yscale += 0.09
	if timer >= 10{
		image_alpha = 1
		image_xscale = 1.8
		image_yscale = 1.8
		timer = 0
		state = "move"
		
	}
}
else if state == "move"{
	image_index = floor(timer/5) mod 6
	x += x_speed
	y += y_speed
	if timer >= 120{
		timer = 0
		state = "idle"
		
	}
}
else if state == "idle"{
	image_index = floor(timer/5) mod 6 + 6
	if timer == 180{
		with obj_card_parent{
			if((abs(grid_col - other.grid_col) + abs(grid_row - other.grid_row)) <= 0 && plant_id != "player" &&  plant_type != "coffee"){
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		hp = 0
	}
}
else if state == "death"{
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