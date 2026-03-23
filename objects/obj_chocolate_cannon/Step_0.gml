if global.is_paused{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

event_inherited(); 
if is_frozen || state == CARD_STATE.SLEEP{
	exit
}



//攻击逻辑

if (attack_timer <= cycle - attack_anim * current_flash_speed) {
    attack_timer++;
}  else if (attack_timer == cycle - 5) {
    event_user(1); // 发射子弹
	attack_timer++;
}else if (attack_timer <= cycle) {
    attack_timer++;
    state = CARD_STATE.ATTACK;
}else {
    if shape == 2{
		event_user(1); // 发射子弹
	}
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}



