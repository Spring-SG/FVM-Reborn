// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0) {
	sprite_index = spr_sawblade_mouse
	if state != ENEMY_STATE.DEAD{
	    timer = 0;
	    state = ENEMY_STATE.DEAD;
	}
    target_plant = noone;  // 清除攻击目标
}
event_inherited();

var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
}

if hp > 0 && state != ENEMY_STATE.DEAD{
	if state == ENEMY_STATE.DIG{
		x -= current_move_speed
		anim_timer++
		image_index = floor(anim_timer/flash_speed) mod 6
		if x <= global.grid_offset_x - 20{
			state = ENEMY_STATE.APPEAR
			sprite_index = spr_sawblade_mouse_appear
			anim_timer = 0
		}
	}
	if state == ENEMY_STATE.APPEAR{
		target_type = "normal"
		anim_timer++
		image_index = floor(anim_timer/flash_speed) mod 14
		if anim_timer >= flash_speed * 14{
			state = ENEMY_STATE.ACTING
			sprite_index = spr_sawblade_mouse_stun
			anim_timer = 0
		}
	}
	if state == ENEMY_STATE.ACTING{
		anim_timer++
		image_index = floor(anim_timer/flash_speed) mod 4
		if anim_timer >= flash_speed * 30{
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_sawblade_mouse
			anim_timer = 0
			move_speed = -0.15
		}
	}
}