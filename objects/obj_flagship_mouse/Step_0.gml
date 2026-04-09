if global.is_paused{
	exit
}
if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0 
	sprite_index = spr_flagship_mouse
}

// Inherit the parent event
event_inherited();
if is_frozen || is_stun || is_scare{
	exit
}

if state == ENEMY_STATE.APPEAR{
	var target_pos = get_world_position_from_grid(7,grid_row)
	if x != target_pos.x+10{
		x = target_pos.x+10
	}
	if hp <= 0{
		timer = 0
		sprite_index = spr_flagship_mouse
		state = ENEMY_STATE.DEAD
	}
	appear_timer++
	image_index = floor(appear_timer/5) mod 16
	if appear_timer >= 16*5-1{
		timer = 0
		sprite_index = spr_flagship_mouse
		state = ENEMY_STATE.NORMAL
	}
	image_alpha = 1
}
else{
	back_timer ++
}

if back_timer >= 380 && state != ENEMY_STATE.ACTING && hp > 0{
	state = ENEMY_STATE.ACTING
	move_speed = -0.45
}

if state == ENEMY_STATE.ACTING{
	if hp <= 0{
		state = ENEMY_STATE.DEAD
		timer = 0
	}
	if back_timer < (380+235){
		if is_slowdown{
			x -= move_speed/2
		}
		else{
			x -= move_speed
		}
		if hp > maxhp*hurt_rate{
			image_index = floor(timer/flash_speed) mod move_anim
		}
		else{
			image_index = floor(timer/flash_speed) mod move_anim + move_anim
		}
	}
	else{
		state = ENEMY_STATE.NORMAL
		timer = 0
		move_speed = 0.45
		back_timer = 0
	}
}