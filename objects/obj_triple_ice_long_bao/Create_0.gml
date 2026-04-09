// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "triple_ice_long_bao"; 
// 设置对象类型和精灵
obj_type = object_index;
sprite_index = spr_triple_ice_long_bao;
current_level = 1
event_user(0)

// ========== 特定属性默认值 ==========

attack_anim = 9;
idle_anim = 12
flash_speed = 5
plant_type = "normal"
is_slowdown = false

