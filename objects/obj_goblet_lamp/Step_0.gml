// 酒杯灯 Step：共用逻辑（暂停/冰冻/减速/深度/血量/水陆/睡眠）全部走父对象 obj_card_parent，
// 这里只保留「成长段」和「产火苗」两段独有逻辑，并接管逐帧动画
// （父对象的动画块被 card_anim_override 跳过）
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

// ========== 成长：grow_time 后播一段长大表现，之后换成正常火苗 ==========
if grow_timer < grow_time{
	grow_timer++
}
else if grow_timer == grow_time{
	state = CARD_STATE.GROW
	global.audio.play(snd_goblet_lamp_grow,0,0)
	grow_timer++
}
else if grow_timer < grow_time+8*current_flash_speed{
	state = CARD_STATE.GROW
	grow_timer++
}
else if grow_timer == grow_time+8*current_flash_speed{
	state = CARD_STATE.IDLE
	flash_offset = 36
	grow_timer++
}

// ========== 动画：比父对象多一个 GROW 段，且整体后移 flash_offset 帧 ==========
if timer < current_flash_speed - 1 {
	timer++;
} else {
	switch (state) {
		case CARD_STATE.IDLE:
			if image_index < idle_anim+flash_offset image_index++;
			else image_index = flash_offset;
			break;

		case CARD_STATE.ATTACK:
			if (image_index >= (idle_anim+1+flash_offset) && image_index <= (idle_anim+1 + attack_anim + flash_offset)) image_index++;
			else image_index = (idle_anim+1)+flash_offset;
			break;

		case CARD_STATE.GROW:
			if (image_index >= (idle_anim+attack_anim+1) && image_index <= (idle_anim+1) + attack_anim+8) image_index++;
			else image_index = (idle_anim+attack_anim+1);
			break;
	}
	timer = 0;
}

// ========== 生产火苗 ==========
if (first_produce == 0) {
	if (attack_timer <= first_produce_delay) {
		attack_timer++;
	} else if (attack_timer <= first_produce_delay + attack_anim * current_flash_speed) {
		attack_timer++;
		state = CARD_STATE.ATTACK;
	} else {
		event_user(1);  // 用户事件1用于生产

		attack_timer = 0;
		state = CARD_STATE.IDLE;
		first_produce = 1;
	}
} else {
	if state != CARD_STATE.GROW{
		if (attack_timer <= cycle - attack_anim * current_flash_speed) {
			attack_timer++;
		} else if (attack_timer <= cycle) {
			attack_timer++;
			state = CARD_STATE.ATTACK;
		} else {
			event_user(1);  // 用户事件1用于生产

			attack_timer = 0;
			state = CARD_STATE.IDLE;
		}
	}
}
