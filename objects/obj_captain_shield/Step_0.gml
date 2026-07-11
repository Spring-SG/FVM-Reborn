if global.is_paused{
	exit
}
timer++
image_index = timer/5 mod 18

if state == "start"{
	x -= 8
	if x <= get_world_position_from_grid(0,0).x{
		state = "corner"
	}
}
if state == "corner"{
	y -= 8
	if y <= get_world_position_from_grid(0,0).y{
		state = "return"
	}
}
if state == "return"{
	x += 8
	if x >= (get_world_position_from_grid(7,0).x +50){
		instance_destroy()
	}
}

with obj_card_parent{
	if grid_col == other.target_col && grid_row == other.target_row &&
	plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
		if hp >= max_hp{
			obj_task_manager.card_loss++
		}
		instance_destroy()
	}
}

var grid_pos = get_grid_position_from_world(x,y)
target_col = grid_pos.col
target_row = grid_pos.row