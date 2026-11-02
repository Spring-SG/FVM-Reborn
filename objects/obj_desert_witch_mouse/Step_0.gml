// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
	sprite_index = spr_desert_witch_mouse
}

event_inherited();



if global.is_paused || is_frozen || is_stun{
	exit
}
if state != ENEMY_STATE.DEAD{
	if perform_timer < perform_cooldown{
		perform_timer++
	}
	else{
		if state != ENEMY_STATE.ACTING{
			timer = 0
			state = ENEMY_STATE.ACTING
			sprite_index = spr_desert_witch_mouse_perform
		}
	}

	if state = ENEMY_STATE.ACTING{
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 23
		}
		else{
			image_index = floor(timer/flash_speed) mod 23 + 23
		}
		if timer == flash_speed * 23 - 1{
			with obj_card_parent{
				if  abs(grid_col - other.grid_col) <= 1 && grid_row == other.grid_row &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if frozen_timer < 600{
						frozen_timer = 600
					}
					if ice_timer < 600{
						ice_timer = 600
					}
				}
			}
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_desert_witch_mouse
			timer = 0
			perform_timer = 0
		}
	}
}