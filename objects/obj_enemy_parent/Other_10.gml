// 飞碟鼠技能3：全场除 BOSS 外的老鼠按 global.enemy_damage_reduction 减免伤害
// （该全局值为减免比例，0 = 无减免；obj_battle 每场战斗开始时重置为 0）
if (!is_boss && global.enemy_damage_reduction > 0) {
	damage_amount *= (1 - global.enemy_damage_reduction);
}

flash_value = 150
if shield_hp > 0{
	if damage_type == "normal"{
		shield_hp -= damage_amount
	}
	else if damage_type == "pierce"{
		shield_hp -= damage_amount
		hp -= damage_amount
	}
	else {
		hp -= damage_amount
	}
}
else{
	hp -= damage_amount
}