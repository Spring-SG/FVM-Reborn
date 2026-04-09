// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
	sprite_index = spr_priest_mouse
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
			sprite_index = spr_priest_mouse_perform
		}
	}

	if state = ENEMY_STATE.ACTING{
		if hp > maxhp*hurt_rate{
			image_index = floor(timer/flash_speed) mod 15
		}
		else{
			image_index = floor(timer/flash_speed) mod 16 + 15
		}
		if timer == flash_speed * 31 - 1{
			with obj_enemy_parent{
				if hp > 0{
					if maxhp < 300{
						maxhp = 300
					}
					if hp <= maxhp - 300{
						hp += 300
					}
					else{
						hp = maxhp
					}
					var inst = instance_create_depth(x,y-45,depth-1,obj_card_heal_effect)
					inst.sprite_index = spr_mouse_heal_effect
				}
			}
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_priest_mouse
			timer = 0
			perform_timer = 0
		}
	}
}