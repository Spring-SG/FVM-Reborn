if global.is_paused{
	exit
}

timer ++

image_index = floor(timer/5) mod 22

if timer == 1 || timer == 5 * 5 + 2 || timer == 8 * 5 + 2{
	with obj_card_parent{
		if grid_col == other.target_col - other.destroy_times && grid_row >= other.target_row-2 && grid_row <= other.target_row &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			instance_destroy()
		}
	}
	destroy_times ++
}

if timer >= 22 * 5 - 1{
	instance_destroy()
}