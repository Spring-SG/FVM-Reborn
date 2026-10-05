if global.is_paused{
	exit
}
timer++
if state == "start"{
	image_index = floor(timer/5) mod 4
	y -= 15
	if y <= -200{
		var target_pos = get_world_position_from_grid(target_col,target_row)
		x = target_pos.x 
		y = target_pos.y - room_height
		state = "drop"
	}
}
if state == "drop"{
	image_index = floor(timer/5) mod 12
	var target_pos = get_world_position_from_grid(target_col,target_row)
	if timer == 4 * 5 + 2{
		with obj_card_parent{
			if abs(grid_col - other.target_col) <= 1 && abs(grid_row - other.target_row) <= 1 &&
			plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"  && plant_id != "soda_bubble"{
				frozen_timer = 240
				ice_timer = 600
			}
		}
	}
	if timer >= 12 * 5 - 1{
		instance_destroy()
	}
}