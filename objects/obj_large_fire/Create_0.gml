// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "large_fire"; 
// 设置对象类型和精灵
obj_type = object_index;
sprite_index = spr_large_fire;
flame_produce = 25;
event_user(0)

// ========== 特定属性默认值 ==========

attack_anim = 18;
idle_anim = 11
if card_equipped_attire_id(plant_id) == "large_fire_gemini"{
	idle_anim = 7
	attack_anim = 19
	if shape >= 1{
		attack_anim = 33
	}
}
flash_speed = 6
first_produce_delay = 60;
plant_type = "normal"

