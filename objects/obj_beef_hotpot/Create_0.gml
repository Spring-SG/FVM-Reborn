// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "beef_hotpot"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_beef_hotpot
}
else if shape == 1{
	sprite_index = spr_beef_hotpot_1
}
else if shape == 2{
	sprite_index = spr_beef_hotpot_2
}

// ========== 特定属性默认值 ==========

attack_anim = 43;
idle_anim = 12
flash_speed = 5
plant_type = "normal"
target_type = "pierce"
is_slowdown = false

awake_anim = 0
anim_timer = 0
wake_timer = 0

