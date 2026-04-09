if global.is_paused{
	exit
}
event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

effect_timer ++

if effect_timer >= 12 * current_flash_speed{
	state = CARD_STATE.RELAX
	image_index = 11
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}

if effect_timer == 4 * current_flash_speed{
	with obj_fog{
		is_blow_away = true
		blow_time = other.cycle
	}
	with obj_enemy_parent{
		if target_type == "air" && array_get_index(other.ignore_list,mouse_id) == -1{
			if !immune_to_ash{
				var inst = instance_create_depth(x,y,-500,obj_mouse_blow_effect)
				inst.sprite_index = sprite_index
				inst.image_index = image_index
				instance_destroy()
			}
			else{
				hp -= other.atk
				event_user(0)
			}
		}
		if other.shape >= 2{
			if target_type == "air" && array_get_index(other.ignore_list,mouse_id) == -1{
				hp -= other.atk
			}
			else if grid_row == other.grid_row{
				hp -= other.atk * 0.5
				event_user(0)
			}
		}
	}
}
if effect_timer >= 4 * current_flash_speed && effect_timer <= 12 * current_flash_speed{
	with obj_enemy_parent{
		if target_type == "air" && array_get_index(other.ignore_list,mouse_id) == -1{
			if x < get_world_position_from_grid(9,0).x{
				x += 6
				if other.shape >= 2{
					x += 6
				}
			}
		}
		if other.shape >= 1 && target_type != "air" && grid_row == other.grid_row && array_get_index(other.ignore_list,mouse_id) == -1{
			if x < get_world_position_from_grid(9,0).x{
				x += 4
			}
		}
	}
}