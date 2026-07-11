// obj_small_furnace 的 Create 事件
// 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "tang_hu_lu"; 
// 设置对象类型和精灵
obj_type = object_index;
sprite_index = spr_tang_hu_lu;
current_level = 1
event_user(0)
if shape == 1{
	sprite_index = spr_tang_hu_lu_1
}
else if shape == 2{
	sprite_index = spr_tang_hu_lu_2
}
// ========== 特定属性默认值 ==========

attack_anim = 15;
idle_anim = 15
flash_speed = 5
plant_type = "normal"
is_slowdown = false
target_type = "air_only"
