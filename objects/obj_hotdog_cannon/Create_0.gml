// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "hotdog_cannon"; 
// 设置对象类型和精灵
obj_type = object_index;

current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_hotdog_cannon;
}
else if shape == 1{
	sprite_index = spr_hotdog_cannon_1
}
else{
	sprite_index = spr_hotdog_cannon_2
}

// ========== 特定属性默认值 ==========

attack_anim = 7;
idle_anim = 12
flash_speed = 5
plant_type = "normal"
is_slowdown = false

target_type = "air"
has_air = false