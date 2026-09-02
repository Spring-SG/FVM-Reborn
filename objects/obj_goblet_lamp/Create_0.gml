// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "goblet_lamp"; 
// 设置对象类型和精灵
obj_type = object_index;
sprite_index = spr_goblet_lamp;
flame_produce = 25;
event_user(0)

// ========== 特定属性默认值 ==========

attack_anim = 18;
idle_anim = 11
first_produce_delay = 60;
plant_type = "normal"

grow_timer = 0
flash_offset = 0
grow_time = 90 * 60
if is_cookbook_equipped("grape_wine"){
	grow_time = 60 * 60
}