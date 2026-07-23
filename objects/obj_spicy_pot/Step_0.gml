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

//检测自身右方是否有敌人
var has_enemy = false
if shape < 2{	
	with(obj_enemy_parent){
		if (abs(grid_row - other.grid_row) <= 1 && grid_col >= other.grid_col && grid_col <= (other.grid_col + 4) && can_target_on(other.target_type,target_type)){
			has_enemy = true
			break
		}
	}
}
else{
	with(obj_enemy_parent){
		if (abs(grid_row - other.grid_row) <= 1 && grid_col >= other.grid_col && grid_col <= (other.grid_col + 5) && can_target_on(other.target_type,target_type)){
			has_enemy = true
			break
		}
	}
}
//攻击逻辑
if (has_enemy) {
	if (attack_timer <= cycle - attack_anim * current_flash_speed) {
	    attack_timer++;
	} else if (attack_timer <= cycle) {
	    attack_timer++;
	    state = CARD_STATE.ATTACK;
	} else {
	    attack_timer = 0;
	    state = CARD_STATE.IDLE;
	}
	if (attack_timer == cycle - 6 * current_flash_speed) && state == CARD_STATE.ATTACK{
		event_user(1) //发射子弹
	}
} else {
	// 没有符合条件的敌人，重置状态
	attack_timer = 0;
	state = CARD_STATE.IDLE;
}


