// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0) {
	if has_tire{
		move_anim = 8
		attack_anim = 1
		death_anim = 15
		sprite_index = spr_tire_mouse
	}
	else{
		move_anim = 8
		attack_anim = 6
		death_anim = 15
		sprite_index = spr_tire_mouse_land
	}
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
		anim_timer++
		if hp > maxhp*hurt_rate{
			image_index = floor(anim_timer/5) mod 16
		}
		else{
			image_index = floor(anim_timer/5) mod 16 + 16
		}
		if anim_timer == 16*5 - 1{
			state = ENEMY_STATE.NORMAL
			anim_timer = 0
			sprite_index = spr_tire_mouse_land
			move_anim = 8
			attack_anim = 6
			death_anim = 15
			atk_cycle = 36
			atk = 10
			move_speed = 0.3
		}
	}
}

if is_frozen || is_stun || scare_timer > 0{
	exit
}

if hp > 0 && state != ENEMY_STATE.DEAD{
	if grid_col <= 5 && has_tire{
		anim_timer = 0
		state = ENEMY_STATE.ACTING
		has_tire = false
		sprite_index = spr_tire_mouse_act
	}
	if state == ENEMY_STATE.ACTING{
		anim_timer++
		if hp > maxhp*hurt_rate{
			image_index = floor(anim_timer/5) mod 10
		}
		else{
			image_index = floor(anim_timer/5) mod 10 + 10
		}
		if anim_timer == 4 * 5 - 1{
			instance_create_depth(x,y,-800,obj_tire_mouse_tire)
		}
		if anim_timer == 10*5 - 1{
			state = ENEMY_STATE.NORMAL
			anim_timer = 0
			sprite_index = spr_tire_mouse_land
			move_anim = 8
			attack_anim = 6
			death_anim = 15
			atk_cycle = 36
			atk = 10
			move_speed = 0.3
		}
	}
}