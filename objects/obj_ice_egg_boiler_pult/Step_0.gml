if global.is_paused{
	exit
}
event_inherited(); 
if state == CARD_STATE.SLEEP{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
// 检测自身右方是否有敌人，并获取最近的敌人
var has_enemy = false
var target_enemy = noone
var min_distance = 10000 // 设置一个足够大的初始值

with(obj_enemy_parent){
    if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type,target_type)){
        var distance = grid_col - other.grid_col
        if (distance < min_distance) {
            min_distance = distance
            target_enemy = id
            has_enemy = true
        }
    }
}

// 存储目标敌人信息
if (has_enemy) {
    target_instance = target_enemy
} else {
    target_instance = noone
}
//攻击逻辑
if (has_enemy) {
    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
        attack_timer++;
    }  else if (attack_timer == cycle - 30) {
        event_user(1); // 发射子弹
		attack_timer++;
    }else if (attack_timer <= cycle) {
		//if shape == 2 && attack_timer == cycle - 20{
		//	event_user(1); // 发射子弹
		//}
        attack_timer++;
        state = CARD_STATE.ATTACK;
    }else {
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
} else {
    // 没有符合条件的敌人，重置状态
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}


