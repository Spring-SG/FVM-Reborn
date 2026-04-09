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

if state == CARD_STATE.SLEEP{
	anim_timer++
	image_index = floor(anim_timer/current_flash_speed) mod 10
	//if anim_timer > 60{
	//	state = CARD_STATE.AWAKE
	//}
}
if state == CARD_STATE.AWAKE{
	wake_timer++
	image_index = floor(wake_timer/current_flash_speed) mod 4 + 10
	if wake_timer >= 5*current_flash_speed{
		sprite_index = spr_oden_pot;
		image_index = 0
		timer = 0
		state = CARD_STATE.IDLE
	}
}

//检测自身右方是否有敌人
var has_enemy = false
if shape < 2{	
	with(obj_enemy_parent){
		if (((grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (other.grid_col + 4)) || (abs(grid_row - other.grid_row)<=4&&abs(x - other.x) <= 100)) && can_target_on(other.target_type,target_type)){
			has_enemy = true
			break
		}
	}
}
else{
	with(obj_enemy_parent){
		if ((grid_row == other.grid_row || abs(x - other.x) <= 100) && can_target_on(other.target_type,target_type)){
			has_enemy = true
			break
		}
	}
}
//攻击逻辑
if state != CARD_STATE.SLEEP && state != CARD_STATE.AWAKE{
	if (has_enemy) {
	    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
	        attack_timer++;
	    }else if (attack_timer == cycle - (attack_anim-3) * current_flash_speed) && state == CARD_STATE.ATTACK{
	        attack_timer++;
        
			event_user(1)
	    } else if (attack_timer <= cycle) {
	        attack_timer++;
	        state = CARD_STATE.ATTACK;
	    } else {
	        attack_timer = 0;
	        state = CARD_STATE.IDLE;
	    }
	} else {
	    // 没有符合条件的敌人，重置状态
	    attack_timer = 0;
	    state = CARD_STATE.IDLE;
	}
}


