// Inherit the parent event
if (grid_col < 0 || grid_col >= global.grid_cols || grid_row < 0 || grid_row >= global.grid_rows) {
	if hp > maxhp - helmet_hp{
		sprite_index = spr_assault_mouse_land_helmet
	}
	else{
		sprite_index = spr_assault_mouse_land
	}

}
else{
	//if global.grid_terrains[grid_row][grid_col].type == "water"{
	//	if sprite_index == spr_assault_mouse_land or sprite_index == spr_assault_mouse_land_helmet{
	//		state = ENEMY_STATE.ACTING
	//		sprite_index = spr_duck_mouse_enter
	//		timer = 0
	//		audio_play_sound(snd_enter_water,0,0)
	//		reversed = false
	//	}
		

	//}
	//else{
	//	if sprite_index == spr_assault_mouse or sprite_index == spr_assault_mouse_helmet{
	//		state = ENEMY_STATE.ACTING
	//		sprite_index = spr_assault_mouse_appear
	//		timer = 0
	//		audio_play_sound(snd_enter_water,0,0)
	//		reversed = true
	//	}
		

	//}
	if hp > maxhp - helmet_hp{
		if global.grid_terrains[grid_row][grid_col].type == "water"{
			sprite_index = spr_assault_mouse_helmet
		}
		else{
			sprite_index = spr_assault_mouse_land_helmet
		}
	}
	else{
		if global.grid_terrains[grid_row][grid_col].type == "water"{
			sprite_index = spr_assault_mouse
		}
		else{
			sprite_index = spr_assault_mouse_land
		}
	}
}
if hp <= maxhp - helmet_hp && not armor_dropped{
	var inst = instance_create_depth(x-25,y-175,depth-1,obj_enemy_armor)
	if sprite_index == spr_assault_mouse || sprite_index == spr_assault_mouse_helmet{
		inst.y += 30
		inst.water = true
	}
	inst.ground_y = y - 45
	inst.type = "helmet"
	inst.x_speed = random_range(3,5)
	inst.y_speed = random_range(-5,-8)
	inst.cgravity = 0.8
	inst.sprite_index = spr_weed_helmet
	armor_dropped = true
}
event_inherited();
if global.is_paused or is_frozen{
	exit
}
if state = ENEMY_STATE.ACTING{
	if hp > maxhp - helmet_hp{
				sprite_index = spr_assault_mouse_appear
			}
			else{
				sprite_index = spr_assault_mouse_appear
			}
	if hp > maxhp * hurt_rate{
		if reversed{
			image_index = 7 - (floor(timer/flash_speed) mod 7)
		}
		else{
			image_index = floor(timer/flash_speed) mod 7
		}
	}
	else{
		if reversed{
			image_index = 7 - (floor(timer/flash_speed) mod 7) + 7
		}
		else{
			image_index = (floor(timer/flash_speed) mod 7) + 7
		}
	}
	if timer >= flash_speed * 7 or hp <= 0{
		state = ENEMY_STATE.NORMAL
		if reversed{
			if hp > maxhp - helmet_hp{
				sprite_index = spr_assault_mouse_land_helmet
			}
			else{
				sprite_index = spr_assault_mouse_land
			}
		}
		else{
			if hp > maxhp - helmet_hp{
				sprite_index = spr_assault_mouse_helmet
			}
			else{
				sprite_index = spr_assault_mouse
			}
		}
	}
}