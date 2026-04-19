if global.is_paused{
	exit
}

var zombie_grid = get_grid_position_from_world(x,y)

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	if timer <= 17 * 5 - 1{
		sprite_index = prev_spr

		image_index = floor(timer /5) mod 17
		
		image_alpha = timer/20
		if timer <= 20{
			y += 15
		}
	}
	else{
		sprite_index = next_spr
		
		image_index = floor((timer-85) /5) mod 10
		
		if timer >= 700{
			hp = 0
		}
		else{
			image_alpha = 1
		}
		x -= 1
	}
	with obj_card_parent{
		if grid_col == other.grid_col && grid_row == other.grid_row &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			instance_destroy()
		}
	}
}
else if state == "death"{
	image_index = 10
	
	image_alpha -= 0.1
	
}

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}

if image_alpha <= 0 && hp <= 0{
	instance_destroy()
}

// 更新僵尸的网格位置和深度

