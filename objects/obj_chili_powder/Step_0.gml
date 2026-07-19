if global.is_paused{
	exit
}

event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

var has_enemy = false
var _range = 121

with obj_enemy_parent{
	if abs(x - other.x) <= _range && grid_row == other.grid_row{
		has_enemy = true
		other.enemy_encounted = true
	}
}

if state != CARD_STATE.SLEEP && state != CARD_STATE.RELAX{
	//攻击逻辑
	if (enemy_encounted) {
	    if (attack_timer <= attack_anim * current_flash_speed) {
	        attack_timer++;
			state = CARD_STATE.ATTACK;
	    }
		if (attack_timer == attack_anim * current_flash_speed){
	        event_user(1); // 发射子弹
		}
	}
	else{
		state = CARD_STATE.IDLE
		attack_timer = 0
	}
}
