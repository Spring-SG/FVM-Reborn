/// 烤蜥蜴投手子弹 Step：通用帧循环 + 落地炸开
event_inherited();
if (global.is_paused) exit;

if (y >= thrower_y) {
	bullet_create_effect(obj_coke_bomb_explode, spr_roast_lizard_pult_bullet_effect);
	instance_destroy();
}