if global.is_paused{
	exit
}
timer++

var grid_pos = get_grid_position_from_world(x,y)

if state == "start"{
	if timer <= 15 * 5 - 1{
		image_index = floor(timer/5) mod 15
	}
	else{
		image_index = 14
	}
	if l_type == 0{
		target_col = grid_pos.col
		x += move_speed
		if x <= get_world_position_from_grid(0,0).x || x >= get_world_position_from_grid(8,0).x{
			image_alpha -= 0.1
			if image_alpha <= 0{
				instance_destroy()
			}
		}
	}
	else{
		y += move_speed
		target_row = grid_pos.row
		if y <= get_world_position_from_grid(0,0).y || y >= get_world_position_from_grid(8,6).y{
			image_alpha -= 0.1
			if image_alpha <= 0{
				instance_destroy()
			}
		}
	}
}

with obj_card_parent{
	if grid_col == other.target_col && grid_row == other.target_row && plant_type != "lilypad" &&
	plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
		if hp >= max_hp{
			obj_task_manager.card_loss++
		}
		instance_destroy()
	}
}