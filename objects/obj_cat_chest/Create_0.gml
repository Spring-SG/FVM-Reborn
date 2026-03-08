// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "cat_chest"; 
// 设置对象类型和精灵
obj_type = object_index;
sprite_index = spr_cat_chest_1;
current_level = 1
event_user(0)

// ========== 特定属性默认值 ==========

attack_anim = 26;
attack_timer = 0
idle_anim = 10
flash_speed = 5
plant_type = "normal"
target_type = "normal"
is_slowdown = false
scared_enemy = []
current_hp = hp
