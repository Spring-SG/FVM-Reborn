if global.is_paused{
	exit
}

timer++

image_angle -= 5

x = center_x + c_radius * cos(degtorad(2.4*-(timer+15)))
y = center_y + c_radius * sin(degtorad(2.4*-(timer+15)))

if timer mod 9 == 0{
	var erase_col = erase_pos[floor(timer/9)].col
	var erase_row = erase_pos[floor(timer/9)].row
	with obj_card_parent{
		if grid_col == erase_col && grid_row == erase_row && plant_id != "player" && plant_type != "coffee"{
			instance_destroy()
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
		}
	}
}

if timer >= 135{
	instance_destroy()
}