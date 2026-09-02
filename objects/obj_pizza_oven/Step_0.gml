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
// 检测自身右方是否有敌人，并获取最远的敌人
var has_enemy = true
var target_enemy = noone
var max_distance = -1 // 设置一个足够小的初始值

with(obj_enemy_parent){
    if (abs(grid_row - other.grid_row) == 0 && grid_col >= other.grid_col && grid_col <= (global.grid_cols) && can_target_on(other.target_type,target_type)){
        var distance = grid_col - other.grid_col
        if (distance > max_distance) {
            max_distance = distance
            target_enemy = id
            has_enemy = true
        }
    }
}

target_instance = target_enemy
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
		b_count = 0
    }
	if (attack_timer == cycle - 4*flash_speed){
		event_user(1)
	}
	if (attack_timer == cycle - 1*flash_speed) && shape >= 2{
		event_user(1); // 发射子弹
	}
} else {
    // 没有符合条件的敌人，重置状态
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}


