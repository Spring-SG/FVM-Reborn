if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = floor(timer/5)
	if timer >= 5*5 - 1{
		timer = 0
		state = "anim"
	}
}
else if state == "anim"{
	image_index = floor(timer/5) mod 12 + 5
	if timer >= 300{
		timer = 0
		state = "idle"
	}
}
else if state == "idle"{
	image_index = floor(timer/5) mod 12 + 24
	if timer >= 12*5 - 1{
		with obj_card_parent{
			if(grid_col == other.grid_col && grid_row == other.grid_row && plant_id != "player" && plant_type != "lilypad" && plant_type != "coffee"){
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		instance_create_depth(x,y,depth,obj_pink_paul_tentacle_drop)
		instance_destroy()
	}
}
else if state == "death"{
	image_index = floor(timer/5) mod 6 + 17
	if timer >= 6*5 - 1{
		timer = 30
		instance_destroy()
	}
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