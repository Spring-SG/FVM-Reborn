if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (9 * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

if global.grid_terrains[grid_pos.row][grid_pos.col].type != "obstacle"{
	current_grid_type = global.grid_terrains[grid_pos.row][grid_pos.col].type
	global.grid_terrains[grid_pos.row][grid_pos.col].type = "obstacle"
}

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = 0
	y += y_speed
	if timer >= 6*5{
		timer = 0
		state = "anim"
		with obj_card_parent{
			if plant_id != "player" && plant_type != "coffee" && grid_row == other.grid_row && grid_col == other.grid_col{
				instance_destroy()
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
			}
		}
	}
}
else if state == "anim"{
	clear_timer ++
	image_index = 0
	if clear_timer >= 90*60{
		hp = 0 
	}
}
else if state == "death"{
	image_index = 0
	if timer >= 1{
		image_alpha -= 0.1
	}
}

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}

if image_alpha <= 0 && hp <= 0{
	instance_destroy()
}


