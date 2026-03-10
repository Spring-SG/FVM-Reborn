// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "coffee_pot"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_coffee_pot
}
else if shape == 1{
	sprite_index = spr_coffee_pot_1
}
else if shape == 2{
	sprite_index = spr_coffee_pot_2
}

// ========== 特定属性默认值 ==========

if global.level_file.level_time_feature == "daytime" && shape < 1{
	state = CARD_STATE.SLEEP
	sprite_index = spr_coffee_pot_sleep
}

attack_anim = 12;
idle_anim = 11
flash_speed = 5
plant_type = "normal"
target_type = "pierce"
is_slowdown = false

awake_anim = 5
anim_timer = 0
wake_timer = 0

