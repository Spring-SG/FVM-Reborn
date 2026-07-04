if global.is_paused{
	exit
}

event_inherited(); 
if is_frozen || state == CARD_STATE.SLEEP{
	exit
}
if state == CARD_STATE.ATTACK{
	flash_speed = 3
}
else{
	flash_speed = 5
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

var has_enemy = false
var _range = 3.5*global.grid_cell_size_x + 20
if shape >= 2{
	_range = 4.5*global.grid_cell_size_x + 20
}


with obj_enemy_parent{
	if x - other.x >0 && x - other.x <= _range && grid_row == other.grid_row && can_target_on(other.target_type,target_type) && hp>0{
		has_enemy = true
		other.enemy_encounted = true
		if array_get_index(other.target_enemy,id) == -1{
			array_push(other.target_enemy,id)
		}
	}
}


//攻击逻辑
if state != CARD_STATE.SLEEP{
	if (has_enemy) {
	    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
	        attack_timer++;
			state = CARD_STATE.IDLE
	    } else if (attack_timer < cycle) {
	        attack_timer++;
	        state = CARD_STATE.ATTACK;
	    } else {
	        attack_timer = 0;
	        state = CARD_STATE.IDLE;
	    }
		if (attack_timer == cycle - 5 * current_flash_speed) && state == CARD_STATE.ATTACK{
        
			event_user(1)
	    }
	} else {
	    // 没有符合条件的敌人，重置状态
		target_enemy = []
	    attack_timer = 0;
	    state = CARD_STATE.IDLE;
	}
}