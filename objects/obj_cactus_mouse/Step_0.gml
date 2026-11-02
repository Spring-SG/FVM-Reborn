// Inherit the parent event

if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0 
	if !throwed{
		sprite_index = spr_cactus_mouse
	}
	else{
		sprite_index = spr_cactus_mouse_drop
	}
}
event_inherited();

if global.is_paused or is_frozen or is_stun{
	exit
}
throw_timer --
if (throw_timer <= 0 || state == ENEMY_STATE.ATTACK) && !throwed && grid_col <= 9 && hp > 0{
	throwed = true
	state = ENEMY_STATE.APPEAR
	timer = 0
}

if state == ENEMY_STATE.APPEAR{
	
	if timer <= (10*flash_speed * 3 - 1){
		sprite_index = spr_cactus_mouse_ready
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 10
		}
		else{
			image_index = floor(timer/flash_speed) mod 10 + 10
		}
	}
	else{
		sprite_index = spr_cactus_mouse_act
		if hp > maxhp * hurt_rate{
			image_index = floor((timer-10*flash_speed * 3)/flash_speed) mod 13
		}
		else{
			image_index = floor((timer-10*flash_speed * 3)/flash_speed) mod 13 + 13
		}
	}
	if timer >= (flash_speed * 43 - 1) or hp <= 0{
		state = ENEMY_STATE.NORMAL
		sprite_index = spr_cactus_mouse_drop
		move_speed = 0.3
	}
	if timer ==( 6 * flash_speed - 1 + 10 * flash_speed * 3){
		var bullet = instance_create_depth(x-10,y-23,-800,obj_cactus_mouse_bullet)
		bullet.row = grid_row
		bullet.target_col = grid_col
	}
	
}
