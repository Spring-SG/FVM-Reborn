if global.is_paused{
	exit
}

timer++
x += 8
image_index = floor(timer/5) mod 8


var grid_pos = get_grid_position_from_world(x,y)
grid_row = grid_pos.row
grid_col = grid_pos.col

with obj_card_parent{
	if grid_col == other.grid_col && grid_row == other.grid_row &&
	plant_id != "player" && plant_type != "coffee" && plant_type != "lilypad" && !invincible && plant_id != "cotton_candy"{
		if hp >= max_hp{
			obj_task_manager.card_loss++
		}
		instance_destroy()
	}
}

if x > 2200 || x < -200 || y > 1200 || y < -200{
	instance_destroy()
}