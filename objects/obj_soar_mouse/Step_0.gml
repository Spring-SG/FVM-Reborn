// Inherit the parent event

event_inherited();
if global.is_paused or is_frozen or is_stun{
	exit
}
if state == ENEMY_STATE.ATTACK{
	timer = 0
	state = ENEMY_STATE.ACTING
}
if state == ENEMY_STATE.ACTING{
	if hp > maxhp * hurt_rate{
		image_index = floor(timer/flash_speed) mod 8
	}
	else{
		image_index = floor(timer/flash_speed) mod 8 + 7
	}
	if timer >= 6 *9 && timer <= 6*16{
		if instance_exists(target_plant){
			if array_get_index(block_list,target_plant.plant_id) == -1{
			
				x -= 2.50
			}
			else{
				x -= 0
			}
		}
		else{
			x -= 2.50
		}
		//y -= 0.50 
	}
	if timer >= flash_speed * 11 & timer <= flash_speed * 15{
		//y += 1.00
	}
	if timer >= flash_speed * 16 or hp <= 0{
		//y = ystart
		state = ENEMY_STATE.NORMAL
	}
}