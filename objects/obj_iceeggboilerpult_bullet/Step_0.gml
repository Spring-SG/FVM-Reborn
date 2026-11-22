/// 冰煮蛋投手子弹 Step：通用帧循环 + 目标中途死亡时落地
event_inherited();
if (global.is_paused) exit;

if (target_enemy != noone && (!instance_exists(target_enemy) || target_enemy.hp <= 0)) {
	if (y >= thrower_y) {
		instance_create_depth(x, y, depth, obj_iceeggboilerpult_bullet_effect);
		instance_destroy();
	}
}