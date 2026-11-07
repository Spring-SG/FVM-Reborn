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
// 在前方三行内索敌：优先最大生命值最高的敌人，生命值相同时选择最靠左（列号最小）的
var has_enemy = false
var target_enemy = noone
var best_hp = -1 // 已选目标的最大生命值
var best_col = 10000 // 已选目标的列号，越小越靠左

with(obj_enemy_parent){
    if (abs(grid_row - other.grid_row) <= 1 && grid_col >= other.grid_col && grid_col <= (global.grid_cols + 1) && can_target_on(other.target_type,target_type)){
        var _hp = maxhp
        var _col = grid_col
        if (_hp > best_hp || (_hp == best_hp && _col < best_col)) {
            best_hp = _hp
            best_col = _col
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
		if shape == 2 && attack_timer == cycle - 20{
			event_user(1); // 发射子弹
		}
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


