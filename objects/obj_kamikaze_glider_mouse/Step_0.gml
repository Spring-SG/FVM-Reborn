// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0) {
	var inst = instance_create_depth(x,y-45,depth,obj_coke_bomb_explode)
	inst.sprite_index = spr_arson_mouse_bullet_effect
	inst.image_xscale = 0.8
	inst.image_yscale = 0.8
	instance_destroy()
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
	if state == ENEMY_STATE.APPEAR{
		anim_timer++
		x -= current_move_speed * move_speed_modify
		image_index = floor(anim_timer/flash_speed) mod 6
		if hp <= (maxhp-helmet_hp) || x <= global.grid_offset_x + 350{
			state = ENEMY_STATE.ACTING
			sprite_index = spr_kamikaze_glider_mouse_drop
			move_speed = 1.2
			anim_timer = 0
		}
	}
	if state == ENEMY_STATE.ACTING{
		anim_timer++
		x -= current_move_speed * move_speed_modify
		image_index = floor(anim_timer/flash_speed) mod 8
		if anim_timer >= flash_speed * 8-1{
			state = ENEMY_STATE.DIG
			sprite_index = spr_kamikaze_glider_mouse_land
			anim_timer = 0
			helmet_hp = 0
		}
	}
	if state == ENEMY_STATE.DIG{
		anim_timer++
		x -= current_move_speed * move_speed_modify
		image_index = floor(anim_timer/flash_speed) mod 33
		if anim_timer >= flash_speed * 33-1{
			with obj_card_parent{
				if grid_col == other.grid_col && grid_row == other.grid_row &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
			var effect_pos = get_world_position_from_grid(grid_col,grid_row)
			var inst = instance_create_depth(effect_pos.x,effect_pos.y,depth,obj_coke_bomb_explode)
			inst.sprite_index = spr_kamikaze_glider_mouse_effect
			instance_destroy()
		}
	}
}