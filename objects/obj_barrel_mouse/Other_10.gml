// 飞碟鼠技能3：全场除 BOSS 外的老鼠按 global.enemy_damage_reduction 减免伤害
if (!is_boss && global.enemy_damage_reduction > 0) {
	damage_amount *= (1 - global.enemy_damage_reduction);
}

flash_value = 150
if state == ENEMY_STATE.ACTING{
	hp -= 0.1 * damage_amount
}
else{
	hp -= damage_amount
}