// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0) {
	sprite_index = spr_hot_ballon_mouse_land
	if state != ENEMY_STATE.DEAD{
	    timer = 0;
	    state = ENEMY_STATE.DEAD;
	}
    target_plant = noone;  // 清除攻击目标
}
event_inherited();

if bomb_col[clamp(grid_col,0,8)] == 0 && state == ENEMY_STATE.APPEAR && hp > 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DIG
	timer = 0
	sprite_index = spr_hot_ballon_mouse_act
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

if hp > 0 && state != ENEMY_STATE.DEAD{
	if state == ENEMY_STATE.APPEAR{
		anim_timer++
		x -= current_move_speed * move_speed_modify
		if hp > maxhp * hurt_rate{
			image_index = floor(anim_timer/flash_speed) mod 8
		}
		else{
			image_index = floor(anim_timer/flash_speed) mod 8 + 8
		}
		if hp <= (maxhp-helmet_hp) || x <= global.grid_offset_x + 150{
			state = ENEMY_STATE.ACTING
			sprite_index = spr_hot_ballon_mouse_drop
			anim_timer = 0
		}
	}
	if state == ENEMY_STATE.ACTING{
		target_type = "normal"
		anim_timer++
		image_index = floor(anim_timer/flash_speed) mod 8
		if anim_timer >= flash_speed * 8 - 1{
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_hot_ballon_mouse_land
			move_speed = 0.3
			anim_timer = 0
			helmet_hp = 0
		}
	}
	if state == ENEMY_STATE.DIG{
		anim_timer++
		if hp > maxhp * hurt_rate{
			image_index = floor(anim_timer/flash_speed) mod 9
		}
		else{
			image_index = floor(anim_timer/flash_speed) mod 9 + 9
		}
		if anim_timer == flash_speed * 6 + 2{
			var bomb_inst = instance_create_depth(x,y-75,-800,obj_hot_ballon_mouse_bullet)
			bomb_inst.target_col = grid_col
			bomb_inst.target_row = grid_row
			bomb_col[clamp(grid_col,0,8)] = 1
		}
		if anim_timer >= flash_speed * 9 - 1{
			state = ENEMY_STATE.APPEAR
			sprite_index = spr_hot_ballon_mouse_air
			anim_timer = 0
		}
	}
}