// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "melon_shield"; 
current_level = 1
// 设置对象类型和精灵
obj_type = object_index;
event_user(0)

// ========== 特定属性默认值 ==========

inner_inst = instance_create_depth(x,y-18,depth+2,obj_melon_shield_inner)
inner_inst.parent_plant = id

sprite_list = [spr_melon_shield_outer_1,spr_melon_shield_outer_2,spr_melon_shield_outer_3]
if shape == 1{
	sprite_list = [spr_melon_shield_1_outer_1,spr_melon_shield_1_outer_2,spr_melon_shield_1_outer_3]
	inner_inst.sprite_index = spr_melon_shield_inner_2
}
if shape == 2{
	sprite_list = [spr_melon_shield_2_outer_1,spr_melon_shield_2_outer_2,spr_melon_shield_2_outer_3]
	inner_inst.sprite_index = spr_melon_shield_inner_3
	inner_inst.y -= 5
}
sprite_index = sprite_list[0]
if card_equipped_attire_id(plant_id) != -1{
	var spr_list = get_attire_info(card_equipped_attire_id(plant_id)).outer_spr
	sprite_list = spr_list[shape]
	var inner_spr_list = get_attire_info(card_equipped_attire_id(plant_id)).inner_spr
	inner_inst.sprite_index = inner_spr_list[shape]
	if card_equipped_attire_id(plant_id) == "melon_virgo"{
		inner_inst.y = y - 42
		if shape == 0{
			inner_inst.y += 4
		}
	}
}
idle_anim = 10
flash_speed = 5
plant_type = "shield_outer"
is_slowdown = false
bleed_damage = 0
current_hp = hp
attack_timer = 0
heal_wait = 60
