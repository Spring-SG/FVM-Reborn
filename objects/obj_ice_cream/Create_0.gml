// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "ice_cream"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
sprite_index = spr_ice_cream;
if shape == 1{
	sprite_index = spr_ice_cream_1
}
else if shape == 2{
	sprite_index = spr_ice_cream_2
}

// ========== 特定属性默认值 ==========

attack_anim = 26;
attack_timer = 0
idle_anim = 16
if shape >= 2{
	idle_anim = 25
}
flash_speed = 5
plant_type = "coffee"
is_slowdown = false
ignore_list = ["ice_cream"]
