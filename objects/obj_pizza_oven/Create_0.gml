// obj_small_furnace 的 Create 事件
// 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "pizza_oven"; 
// 设置对象类型和精灵
event_user(0)
if shape == 0{
	sprite_index = spr_pizza_oven
}
else if shape == 1{
	sprite_index = spr_pizza_oven_1
}
else if shape == 2{
	sprite_index = spr_pizza_oven_2
}
// ========== 特定属性默认值 ==========

attack_anim = 10;
idle_anim = 12
flash_speed = 5
plant_type = "normal"
is_slowdown = false
target_type = "air"
target_instance = noone

b_count = 0