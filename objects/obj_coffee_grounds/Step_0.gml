if global.is_paused{
	exit
}

event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

attack_timer++

var upgrade_data = get_plant_data_with_skill(plant_id, shape,current_level,skill);
cycle = upgrade_data[? "cycle"]

if attack_timer == 1{
	with obj_card_parent{
		if plant_id != "player"{
			if(other.shape == 0 && grid_row == other.grid_row && grid_col == other.grid_col)
			||(other.shape == 1 && grid_row >= other.grid_row-1 && grid_row <= other.grid_row+1 && grid_col >= other.grid_col-1 && grid_col <= other.grid_col+1)
			||other.shape >= 2{
				awake_buff_timer += other.cycle
			}
		}
	}
}
if attack_timer > current_flash_speed * 13 - 1{
	instance_destroy()
}