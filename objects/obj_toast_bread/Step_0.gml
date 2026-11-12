// 土司面包 Step：共用逻辑（暂停/冰冻/减速/深度/血量/水陆/睡眠）全部走父对象 obj_card_parent，
// 只剩「按血量切换受损外形」这一处独有表现，动画由本对象接管
// （父对象的动画块被 card_anim_override 跳过）
if global.is_paused{
	exit
}
event_inherited();
if is_frozen{
	exit
}

// 受损分级：血量越低，切到后面一段外形
var flash_offset = 0
if hp <= 0.67 * max_hp flash_offset = 12
if hp <= 0.33 * max_hp flash_offset = 24

var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
if timer < current_flash_speed - 1 {
	timer++;
} else {
	switch (state) {
		case CARD_STATE.IDLE:
			if image_index < (11+flash_offset) image_index++;
			else image_index = flash_offset;
			break;

		case CARD_STATE.ATTACK:
			if (image_index >= 12 && image_index <= 12 + attack_anim) image_index++;
			else image_index = 12;
			break;
	}
	timer = 0;
}
