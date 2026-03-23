// Inherit the parent event
if hp <= 0  && state != ENEMY_STATE.DEAD{
		timer = 0
		state = ENEMY_STATE.DEAD
		if (grid_col < 0 || grid_col >= global.grid_cols || grid_row < 0 || grid_row >= global.grid_rows){
			sprite_index = spr_diver_mouse_land
		}
		else{
			if global.grid_terrains[grid_row][grid_col].type == "water"{
				sprite_index = spr_diver_mouse
				death_anim = 10
			}
			else{
				sprite_index = spr_diver_mouse_land
				death_anim = 13
			}
		}
		
	}
if (grid_col < 0 || grid_col >= global.grid_cols || grid_row < 0 || grid_row >= global.grid_rows) {
	sprite_index = spr_diver_mouse_land
	move_anim = 8
	death_anim = 13
}
else{
	if state != ENEMY_STATE.DEAD{
		if global.grid_terrains[grid_row][grid_col].type == "water" && not entered{
			if sprite_index == spr_diver_mouse_land{
				state = ENEMY_STATE.ACTING
				sprite_index = spr_diver_mouse_enter
				timer = 0
				audio_play_sound(snd_enter_water,0,0)
				reversed = false
			}
			move_anim = 4
			death_anim = 10
		}
		//else if global.grid_terrains[grid_row][grid_col].type != "water" && entered{
		//	if sprite_index == spr_diver_mouse{
		//		state = ENEMY_STATE.ACTING
		//		sprite_index = spr_diver_mouse_enter
		//		timer = 0
		//		audio_play_sound(snd_enter_water,0,0)
		//		reversed = true
		//	}
		//	move_anim = 8
		//	death_anim = 13
		//}
	}
}
if state == ENEMY_STATE.ATTACK && entered{
	if instance_exists(target_plant) && not up{
		sprite_index = spr_diver_mouse_up
		state = ENEMY_STATE.ACTING
		timer = 0
	}
	if !instance_exists(target_plant) && up{
		sprite_index = spr_diver_mouse_up
		state = ENEMY_STATE.ACTING
		timer = 0
	}
}

event_inherited();
if global.is_paused or is_frozen{
	exit
}
if state == ENEMY_STATE.ACTING{
	if not entered{
		if hp <= 0{
			timer = 0
			state = ENEMY_STATE.DEAD
			if reversed{
				sprite_index = spr_diver_mouse_land
			}
			else{
				sprite_index = spr_diver_mouse
			}
		
		}
		x -= move_speed
		if hp > maxhp * hurt_rate{
			if reversed{
				image_index = 9 - (floor(timer/flash_speed) mod 9)
			}
			else{
				image_index = floor(timer/flash_speed) mod 9
			}
		}
		else{
			if reversed{
				image_index = 9 - (floor(timer/flash_speed) mod 9) + 8
			}
			else{
				image_index = (floor(timer/flash_speed) mod 9) + 8
			}
		}
		if timer >= flash_speed * 9 or hp <= 0{
			state = ENEMY_STATE.NORMAL
			
			if reversed{
				sprite_index = spr_diver_mouse_land
				entered = false
			}
			else{
				sprite_index = spr_diver_mouse
				entered = true
			}
			if hp <= 0{
				timer = 0
				state = ENEMY_STATE.DEAD
			}
		}
	}
	else{
		timer++
		if not up{
			if hp > hp*hurt_rate{
				image_index = floor(timer/flash_speed) mod 4
			}
			else{
				image_index = floor(timer/flash_speed) mod 4 + 3
			}
		}
		else{
			if hp > hp*hurt_rate{
				image_index = 4 - (floor(timer/flash_speed) mod 4)
			}
			else{
				image_index = 4 - (floor(timer/flash_speed) mod 4) + 3
			}
			
		}
		if timer >= flash_speed * 4 or hp <= 0{
			state = ENEMY_STATE.NORMAL
			
			sprite_index = spr_diver_mouse
			up = !up
			
			if hp <= 0{
				timer = 0
				state = ENEMY_STATE.DEAD
			}
		}
	}
}

if sprite_index == spr_diver_mouse && state != ENEMY_STATE.ATTACK{
	target_type = "diver"
}
else{
	target_type = "normal"
}