// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0) {
	sprite_index = spr_aircraft_carrier
	if state != ENEMY_STATE.DEAD{
	    timer = 0;
	    state = ENEMY_STATE.DEAD;
	}
    target_plant = noone;  // 清除攻击目标
}
event_inherited();

if x > get_world_position_from_grid(9,grid_row).x{
	move_speed = 1.2
}
else{
	move_speed = 0.6
}

var current_move_speed = 0
if is_slowdown{
	flash_speed = 10
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 5
	current_move_speed = move_speed
}

if hp > 0 && state != ENEMY_STATE.DEAD{
	if state == ENEMY_STATE.APPEAR{
		anim_timer++
		x -= current_move_speed * move_speed_modify
		if hp > maxhp*hurt_rate{
			image_index = floor(anim_timer/flash_speed) mod 4
		}
		else{
			image_index = floor(anim_timer/flash_speed) mod 4 + 4
		}
		if x <= get_world_position_from_grid(7,grid_row).x{
			anim_timer = 0
			state = ENEMY_STATE.ACTING
			if grid_row == 0{
				sprite_index = spr_aircraft_carrier_release_2
			}
			else if grid_row == global.grid_rows-1{
				sprite_index = spr_aircraft_carrier_release_3
			}
			else{
				sprite_index = spr_aircraft_carrier_release_1
			}
		}
	}
	if state == ENEMY_STATE.ACTING{
		anim_timer++
		if hp > maxhp*hurt_rate{
			image_index = floor(anim_timer/flash_speed) mod 53
		}
		else{
			image_index = floor(anim_timer/flash_speed) mod 53 + 53
		}
		if anim_timer == 39*flash_speed-1{
			var summon_grid_pos = get_grid_position_from_world(x,y)
			instance_create_depth(summon_grid_pos.x+55,summon_grid_pos.y+38,depth,obj_machine_bomb_mouse)
			if grid_row > 0{
				instance_create_depth(summon_grid_pos.x+55,summon_grid_pos.y+38-global.grid_cell_size_y,depth,obj_machine_bomb_mouse)
			}
			if grid_row < global.grid_rows-1{
				instance_create_depth(summon_grid_pos.x+55,summon_grid_pos.y+38+global.grid_cell_size_y,depth,obj_machine_bomb_mouse)
			}
		}
		if anim_timer == 53*flash_speed - 1{
			state = ENEMY_STATE.DIG
			anim_timer = 0
			sprite_index = spr_aircraft_carrier
		}
	}
	if state == ENEMY_STATE.DIG{
		anim_timer++
		x += current_move_speed * move_speed_modify
		if hp > maxhp*hurt_rate{
			image_index = floor(anim_timer/flash_speed) mod 4
		}
		else{
			image_index = floor(anim_timer/flash_speed) mod 4 + 4
		}
		if x >= room_width{
			instance_destroy()
		}
	}
}