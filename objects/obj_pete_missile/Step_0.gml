if global.is_paused{
	exit
}
timer++
if state == "start"{
	image_index = 0
	y -= 15
	if y <= -200{
		var target_pos = get_world_position_from_grid(target_col,target_row)
		x = target_pos.x 
		y = target_pos.y - room_height
		state = "drop"
	}
}
if state == "drop"{
	image_index = 1
	var target_pos = get_world_position_from_grid(target_col,target_row)
	y += 15
	if y >= target_pos.y{
		with obj_card_parent{
			if grid_col == other.target_col &&grid_row == other.target_row &&plant_id != "player"{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		instance_create_depth(x,y,-200,obj_arno_bullet_effect)
		instance_destroy()
	}
}