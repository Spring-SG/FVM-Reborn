// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "pineapple_explosive_bread"; 
current_level = 1
// 设置对象类型和精灵
obj_type = object_index;
event_user(0)

// ========== 特定属性默认值 ==========

sprite_list = [spr_pineapple_explosive_bread_0_0,spr_pineapple_explosive_bread_0_1,spr_pineapple_explosive_bread_0_2]
if shape == 1{
	sprite_list = [spr_pineapple_explosive_bread_1_0,spr_pineapple_explosive_bread_1_1,spr_pineapple_explosive_bread_1_2]
}
if shape == 2{
	sprite_list = [spr_pineapple_explosive_bread_2_0,spr_pineapple_explosive_bread_2_1,spr_pineapple_explosive_bread_2_2]
}
sprite_index = sprite_list[0]
idle_anim = 12
flash_speed = 5
plant_type = "normal"
is_slowdown = false
attack_timer = 0
