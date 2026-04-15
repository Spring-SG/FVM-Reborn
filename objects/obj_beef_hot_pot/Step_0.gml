if global.is_paused{
	exit
}
event_inherited();
if is_frozen || state == CARD_STATE.SLEEP{
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
		if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (other.grid_col + 4) && can_target_on(other.target_type,target_type)){
			has_enemy = true
			break
		}
	}
}
else{
	with(obj_enemy_parent){
		if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (other.grid_col + 5) && can_target_on(other.target_type,target_type)){
			has_enemy = true
			break
		}
	}
}
//攻击逻辑
var wait_time = cycle - attack_anim * current_flash_speed;
if (wait_time < 0) wait_time = 0;

if (has_enemy) {
	if (attack_timer < wait_time) {
		// 等待阶段
		attack_timer++;
		state = CARD_STATE.IDLE;
		damage_timer = 0;
	} else if (attack_timer < wait_time + attack_anim * current_flash_speed) {
		// 执行动作阶段
		attack_timer++;
		state = CARD_STATE.ATTACK;

		// 第7帧及之后开始喷火造成伤害
		if (image_index >= (idle_anim + 1 + 7) && image_index <= (idle_anim + 1 + attack_anim)) {
				event_user(1);
		} else {
				damage_timer = 0;
		}
	} else {
		attack_timer = 0;
		state = CARD_STATE.IDLE;
		damage_timer = 0;
	}
} else {
	if (attack_timer >= wait_time) {
		attack_timer = 0;
	} else {
		attack_timer++;
	}
	state = CARD_STATE.IDLE;
	damage_timer = 0; 
}
