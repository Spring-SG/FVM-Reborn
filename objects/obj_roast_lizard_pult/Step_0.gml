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
// 检测自身右方是否有敌人，并获取最近的敌人
var has_enemy = false
var target_enemy_list = [noone,noone,noone]
var min_distance_list = [room_width,room_width,room_width] //同时存储上中下三个目标的距离

with(obj_enemy_parent){
    if (abs(grid_row - other.grid_row) <= 1 && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type,target_type)){
		var ins_slot = 1 + grid_row - other.grid_row //根据行数差确定保存槽位
        var distance = grid_col - other.grid_col
        if (distance < min_distance_list[ins_slot]) {
            min_distance_list[ins_slot] = distance
            target_enemy_list[ins_slot] = id
            has_enemy = true
        }
    }
}

// 存储目标敌人信息
if (has_enemy) {
    target_instance_list = target_enemy_list
} else {
    target_instance_list = [noone,noone,noone]
}
//攻击逻辑
if (has_enemy) {
    if (attack_timer <= cycle - attack_anim * current_flash_speed) {
        attack_timer++;
    }  else if (attack_timer == cycle - 15) {
        event_user(1); // 发射子弹
		attack_count ++
		attack_timer++;
    }else if (attack_timer <= cycle) {
		if shape >= 1 && attack_timer == cycle - 5{
			event_user(1); // 发射子弹
			attack_count ++
		}
        attack_timer++;
        state = CARD_STATE.ATTACK;
    }else {
		attack_count = 0
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }
} else {
    // 没有符合条件的敌人，重置状态
	attack_count = 0
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}


