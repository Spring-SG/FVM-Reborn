if global.is_paused{
	exit
}
if state == CARD_STATE.IDLE{
	flash_speed = 5
}
else if state == CARD_STATE.ATTACK{
	flash_speed = 4
}
event_inherited(); 
if is_frozen{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

var sleep_anim = 19
if shape >= 1 sleep_anim = 11

if state == CARD_STATE.SLEEP{
	anim_timer++
	image_index = floor(anim_timer/current_flash_speed) mod sleep_anim
	//if anim_timer > 60{
	//	state = CARD_STATE.AWAKE
	//}
}
if state == CARD_STATE.AWAKE{
	wake_timer++
	image_index = floor(wake_timer/current_flash_speed) mod 6 + sleep_anim
	if wake_timer >= 5*current_flash_speed{
		sprite_index = spr_rotating_coffee_pot;
		if shape >= 1{
			sprite_index = spr_rotating_coffee_pot_1
		}
		image_index = 0
		timer = 0
		state = CARD_STATE.IDLE
	}
}

//检测自身右方是否有敌人
var has_enemy = false
	
	var _x = x;
	var _y = y;
	var _range = 220
	if shape == 2{
		_range = 350
	}

	with (obj_enemy_parent) {
		
			if (can_target_on(other.target_type,target_type) && point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-other.range&&grid_row <= other.grid_row+other.range) {
		        has_enemy = true
		    }
		
	}

//攻击逻辑
if state != CARD_STATE.SLEEP && state != CARD_STATE.AWAKE{
	if (has_enemy) {
	    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
	        attack_timer++;
	    } else if (attack_timer < cycle) {
	        attack_timer++;
	        state = CARD_STATE.ATTACK;
	    } else {
	        attack_timer = 0;
	        state = CARD_STATE.IDLE;
	    }
		if (attack_timer == cycle - 8 * current_flash_speed) && state == CARD_STATE.ATTACK{
        
			event_user(1)
	    }
		if (attack_timer == cycle - 12 * current_flash_speed) && state == CARD_STATE.ATTACK{
        
			audio_play_sound(snd_coffee_pot_attack,0,0)
	    }
	} else {
	    // 没有符合条件的敌人，重置状态
	    attack_timer = 0;
	    state = CARD_STATE.IDLE;
	}
}


