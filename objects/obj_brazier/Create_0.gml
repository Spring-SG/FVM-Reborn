// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "brazier"; 
// 设置对象类型和精灵

event_user(0)
sprite_index = spr_brazier;
if shape == 1{
	sprite_index = spr_brazier_1
}
else if shape == 2{
	sprite_index = spr_brazier_2
}
if card_equipped_attire_id(plant_id) != -1{
	var spr_list = get_attire_info(card_equipped_attire_id(plant_id)).spr
	sprite_index = spr_list[shape]
}
// ========== 特定属性默认值 ==========
if shape >= 1{
	hp *= 5
	max_hp *= 5
}
attack_anim = 26;
idle_anim = 11
flash_speed = 5
plant_type = "normal"
is_slowdown = false

