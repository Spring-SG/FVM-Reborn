// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "stinky_tofu_pult"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_stinky_tofu_pult
}
else if shape == 1{
	sprite_index = spr_stinky_tofu_pult_1
}
else if shape == 2{
	sprite_index = spr_stinky_tofu_pult_2
}

// ========== 特定属性默认值 ==========

attack_anim = 7;
idle_anim = 11
flash_speed = 5
plant_type = "normal"
is_slowdown = false
target_instance = noone
if shape < 2{
	stinky_tofu_cooldown = 480
	stinky_tofu_timer = 480
}
else{
	stinky_tofu_cooldown = 300
	stinky_tofu_timer = 300
}
target_type = "throw"