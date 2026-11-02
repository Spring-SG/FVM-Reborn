// Inherit the parent event

event_inherited();

if state == ENEMY_STATE.ATTACK{
	state = ENEMY_STATE.ACTING
	timer = 0
}

if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
}

var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
}

if state == ENEMY_STATE.ACTING{
	if (hp/maxhp  > hurt_rate) {
		image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2);
	} else {
		image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2 + attack_anim);
	}
	if timer == 10 * flash_speed{
		if instance_exists(target_plant){
			with target_plant{
				if !invincible{
					hp -= 900
					event_user(2)
				}
			}
		}
	}
	if timer >= attack_anim * flash_speed -1{
		state = ENEMY_STATE.NORMAL
		timer = 0
	}
}