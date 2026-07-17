// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
	sprite_index = spr_trumpeter_mouse
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
			sprite_index = spr_trumpeter_mouse_perform
		}
	}

	if state = ENEMY_STATE.ACTING{
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 19
		}
		else{
			image_index = floor(timer/flash_speed) mod 19 + 19
		}
		if timer == flash_speed * 19 - 1{
			with obj_enemy_parent{
				if point_distance(x,y,other.x,other.y) <= 250 && scare_timer <= 0 && left_move_flashs <= 0{
					if grid_row == other.grid_row - 1 && global.row_feature[clamp(grid_row,0,global.grid_rows-1)] == global.row_feature[clamp(grid_row+1,0,global.grid_rows-1)] && grid_row < global.grid_rows-1{
						scare_timer = 30
						left_move_flashs = 30
						y_move = global.grid_cell_size_y/left_move_flashs
					}
					if grid_row == other.grid_row + 1 && global.row_feature[clamp(grid_row,0,global.grid_rows-1)] == global.row_feature[clamp(grid_row-1,0,global.grid_rows-1)] && grid_row > 0{
						scare_timer = 30
						left_move_flashs = 30
						y_move = -global.grid_cell_size_y/left_move_flashs
					}
				}
			}
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_trumpeter_mouse
			timer = 0
			perform_timer = 0
		}
	}
}