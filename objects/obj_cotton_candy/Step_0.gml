// Inherit the parent event
if global.is_paused{
	exit
}

remove_timer ++

if remove_timer == 1{
	with obj_card_parent{
		if grid_row == other.grid_row && grid_col == other.grid_col && plant_id == "cotton_candy" && id != other.id{
			instance_destroy()
		}
	}
}

event_inherited();

if hp <= 0.33 * max_hp{
	sprite_index = spr_list[2]
}
else if hp <= 0.67 * max_hp{
	sprite_index = spr_list[1]
}
else{
	sprite_index = spr_list[0]
}

depth = calculate_plant_depth(grid_col,grid_row,"lilypad")

with obj_cloud{
	if is_hole && col > 1 &&
	((other.shape <= 1 && row == other.grid_row && abs(col - other.grid_col) <= 1)||
	(other.shape >= 2 && abs(row - other.grid_row) <= 1 && abs(col - other.grid_col) <= 1)){
		is_hole = false
		image_alpha = 1
		other.hole_count --
	}
}
if hole_count <= 0{
	instance_destroy()
}
if !on_lava{
	if shape == 2{
		if hole_count > 0{
			sprite_index = spr_list[3-hole_count]
		}
		else{
			sprite_index = spr_list[2]
		}
	}
}
if on_lava{
	plant_type = "lilypad"
}