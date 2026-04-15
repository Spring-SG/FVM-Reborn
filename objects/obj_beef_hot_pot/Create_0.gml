event_inherited();  // 继承父对象属性
plant_id = "beef_hot_pot";
event_user(0)
if shape == 0{
	sprite_index = spr_beef_hot_pot
}
else if shape == 1{
	sprite_index = spr_beef_hot_pot_1
}
else if shape == 2{
	sprite_index = spr_beef_hot_pot_2
}
// ========== 特定属性默认值 ==========

attack_anim = 44;
idle_anim = 11
flash_speed = 5
plant_type = "normal"
target_type = "pierce"
is_slowdown = false

// 用于追踪火锅伤害判定的计时器
damage_timer = 0;