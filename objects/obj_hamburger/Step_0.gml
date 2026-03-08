if global.is_paused{
	exit
}

event_inherited(); 
if is_frozen{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

var has_enemy = false
var _range = 200
if shape >= 1{
	_range = 3.5*global.grid_cell_size_x + 20
}

with obj_enemy_parent{
	if x - other.x >0 && x - other.x <= _range && grid_row == other.grid_row && can_target_on(other.target_type,target_type){
		has_enemy = true
		other.enemy_encounted = true
		array_push(other.target_enemy,id)
	}
}

if state == CARD_STATE.RELAX{
	var eat_anim = 12
	if shape >= 1 eat_anim = 10
	relax_timer ++
	if relax_timer < cycle - 10 * current_flash_speed{
		image_index = floor(relax_timer/current_flash_speed) mod eat_anim
	}
	else{
		image_index = floor(relax_timer/current_flash_speed) mod 10 + eat_anim
	}
	if relax_timer >= cycle{
		state = CARD_STATE.IDLE
		relax_timer = 0
		timer = 0
		attack_timer = 0
		sprite_index = spr_hamburger
		if shape == 1 sprite_index = spr_hamburger_1
		if shape == 2 sprite_index = spr_hamburger_2
		image_index = 0
	}
}

if state != CARD_STATE.SLEEP && state != CARD_STATE.RELAX{
	//攻击逻辑
	if (enemy_encounted) {
	    if (attack_timer <= attack_anim * current_flash_speed) {
	        attack_timer++;
			state = CARD_STATE.ATTACK;
	    }  else {
			if enemy_hitted{
				relax_timer = 0
		        state = CARD_STATE.RELAX;
				sprite_index = spr_hamburger_eat
				if shape == 1 sprite_index = spr_hamburger_eat_1
				if shape == 2 sprite_index = spr_hamburger_eat_2
				enemy_hitted = false
			}
			attack_timer = 0;
			enemy_encounted = false
	    }
		if (attack_timer == attack_anim * current_flash_speed * 0.5){
			audio_play_sound(snd_hamburger_eat,0,0)
	        event_user(1); // 发射子弹
		}
	}
	else{
		state = CARD_STATE.IDLE
		attack_timer = 0
	}
}