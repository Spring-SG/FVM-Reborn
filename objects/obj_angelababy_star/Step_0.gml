if global.is_paused{
	exit
}

timer ++
image_index = floor(timer/5) mod 28
if timer == 28*5-1{
	instance_destroy()
}
if timer == 1 || timer == 10 * 5 - 1 || timer == 24 * 5 - 1{
	with obj_card_parent{
		if grid_col == other.erase_cols[other.erase_times] && grid_row == other.grid_row &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			instance_destroy()
		}
	}
	erase_times ++
}