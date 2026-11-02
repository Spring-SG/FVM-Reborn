// Inherit the parent event
if global.is_paused{
	exit
}

if hp <= 0 && state != ENEMY_STATE.DEAD{
	sprite_index = spr_javelin_giant_mouse
	state = ENEMY_STATE.DEAD
	timer = 0
}

event_inherited();

if is_frozen || is_stun || scare_timer > 0{
	exit
}

if state == ENEMY_STATE.ATTACK{
	state = ENEMY_STATE.ACTING
	timer = 0
}

if grid_row <= 6 && hp > 0 && state != ENEMY_STATE.DEAD && state != ENEMY_STATE.ACTING && state != ENEMY_STATE.DIG && !throwed{
	state = ENEMY_STATE.DIG
	timer = 0
	sprite_index = spr_javelin_giant_mouse_act
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

if state == ENEMY_STATE.ACTING{
	if (hp/maxhp  > hurt_rate) {
		image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2);
	} else {
		image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2 + attack_anim);
	}
	if timer == 10 * flash_speed{
		if instance_exists(target_plant){
			with target_plant{
				if !invincible{
					hp -= 900
					event_user(2)
				}
			}
		}
	}
	if timer >= attack_anim * flash_speed -1{
		state = ENEMY_STATE.NORMAL
		timer = 0
	}
}

if state == ENEMY_STATE.DIG{
	if (hp/maxhp  > hurt_rate) {
		image_index = (floor(timer / flash_speed) mod 18);
	} else {
		image_index = (floor(timer / flash_speed) mod 18 + 18);
	}
	if timer == 13 * flash_speed + 2{
		var target_row = grid_row
		var target_col = irandom_range(2,4)
		with obj_card_parent{
			if grid_col == target_col && grid_row == target_row &&
			plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		var spear_pos = get_world_position_from_grid(target_col,target_row)
		var spear_inst = instance_create_depth(spear_pos.x,spear_pos.y+15,-800,obj_coke_bomb_explode)
		spear_inst.sprite_index = spr_javelin_giant_mouse_bullet
	}
	if timer >= 18 * flash_speed -1{
		state = ENEMY_STATE.NORMAL
		timer = 0
		sprite_index = spr_javelin_giant_mouse
		throwed = true
	}
}