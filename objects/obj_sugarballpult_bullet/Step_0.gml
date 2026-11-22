/// 糖球投手子弹 Step：通用帧循环 + 目标中途死亡时落地
event_inherited();
if (global.is_paused) exit;

if (target_enemy != noone && (!instance_exists(target_enemy) || target_enemy.hp <= 0)) {
	if (y >= thrower_y) {
		bullet_create_effect(obj_coke_bomb_explode, spr_sugar_ball_pult_bullet_effect);
		instance_destroy();
	}
}