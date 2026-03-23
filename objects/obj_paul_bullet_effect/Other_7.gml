with obj_card_parent{
	if(grid_col == other.col && grid_row == other.row && plant_id != "player" && plant_type != "lilypad" && plant_type != "coffee"){
		if hp >= max_hp{
			obj_task_manager.card_loss++
		}
		instance_destroy()
	}
}

instance_destroy()