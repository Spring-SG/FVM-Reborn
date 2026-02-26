// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	timer = 0
		state = ENEMY_STATE.DEAD
		sprite_index = spr_frog_prince_mouse
		move_anim = 10
		attack_anim = 6
		move_speed = 0.3
}
event_inherited();
if grid_col <0 {
	sprite_index = spr_frog_prince_mouse_land
}
if global.is_paused or is_frozen{
	exit
}
if state == ENEMY_STATE.ATTACK && sprite_index == spr_frog_prince_mouse_frog{
	timer = 0
	state = ENEMY_STATE.ACTING
}
if state == ENEMY_STATE.ACTING{
	if hp <= 0{
		state = ENEMY_STATE.NORMAL
		sprite_index = spr_frog_prince_mouse
		move_anim = 10
		attack_anim = 6
		move_speed = 0.3
	}
	if sprite_index == spr_frog_prince_mouse_enter{
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 10
		}
		else{
			image_index = floor(timer/flash_speed) mod 10 + 9
		}
		if timer >= flash_speed * 4{
			if is_slowdown{
				x -= 1.1
			}
			else{
				x -= 2.25
			}
		}
		if timer >= flash_speed * 10 or hp <= 0{
			audio_play_sound(snd_enter_water,0,0)
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_frog_prince_mouse_frog
			if hp <= 0{
				sprite_index = spr_frog_prince_mouse
				move_anim = 10
				attack_anim = 6
				move_speed = 0.3
			}
		}
	}
	else{
		if instance_exists(target_plant){
			if array_get_index(block_list,target_plant.plant_id) == -1{
			
				x -= 2.50
			}
			else{
				x -= 0
			}
		}
		else{
			x -= 2.50
		}
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/flash_speed) mod attack_anim + move_anim * 2 - 1
		}
		else{
			image_index = floor(timer/flash_speed) mod attack_anim + attack_anim + move_anim * 2 - 1
		}
		
		if timer >= flash_speed * 10 or hp <= 0{
			audio_play_sound(snd_enter_water,0,0)
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_frog_prince_mouse
			move_anim = 10
			attack_anim = 6
			move_speed = 0.3
		}
	}
}