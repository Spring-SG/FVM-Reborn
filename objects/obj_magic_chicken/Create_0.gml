// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "magic_chicken"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
sprite_index = spr_magic_chicken;

// ========== 特定属性默认值 ==========

attack_anim = 29;
attack_timer = 0
idle_anim = 29
flash_speed = 5
plant_type = "coffee"
is_slowdown = false
current_hp = hp

target_card = global.prev_place_id
