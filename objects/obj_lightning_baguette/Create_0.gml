// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "lightning_baguette"; 
current_level = 1
// 设置对象类型和精灵
obj_type = object_index;
event_user(0)

// ========== 特定属性默认值 ==========

sprite_index = spr_lightning_baguette
if shape == 1{
	sprite_index = spr_lightning_baguette_1
}
if shape == 2{
	sprite_index = spr_lightning_baguette_2
}
idle_anim = 9
flash_speed = 5
attack_anim = 6
plant_type = "normal"
is_slowdown = false
attack_timer = 0

can_mouse_list = ["can_mouse"]

is_parent = false
banding_bread = noone
