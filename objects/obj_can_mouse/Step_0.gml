// Inherit the parent event
if global.is_paused{
	exit
}
if hp <= 0 && state != ENEMY_STATE.DEAD{
	timer = 0
	state = ENEMY_STATE.DEAD
	if !can_dropped{
		sprite_index = spr_can_mouse_with_can
	}
	else{
		sprite_index = spr_can_mouse
	}
}

event_inherited();

if is_frozen || is_stun{
	exit
}

var target_pos = get_world_position_from_grid(0,target_row)

if state == ENEMY_STATE.ACTING{
	sprite_index = spr_can_mouse_drop
	if y < target_pos.y+39{
		x += chspeed
		y -= cvspeed
		cvspeed -= cgravity
		image_index = floor(timer/3) mod 9
	}
	else{
		y = target_pos.y+39
		land_timer ++
		image_index = floor(land_timer/flash_speed) mod 10 + 9
		if land_timer >= 10*flash_speed-1{
			y = target_pos.y+38
			sprite_index = spr_can_mouse
			state = ENEMY_STATE.NORMAL
			timer = 0
		}
	}	
}

