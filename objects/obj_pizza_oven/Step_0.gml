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

//攻击逻辑

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



