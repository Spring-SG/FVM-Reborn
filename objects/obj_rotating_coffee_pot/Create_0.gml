// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "rotating_coffee_pot"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
if shape == 0{
	sprite_index = spr_rotating_coffee_pot
}
else if shape == 1{
	sprite_index = spr_rotating_coffee_pot_1
}
else if shape == 2{
	sprite_index = spr_rotating_coffee_pot_2
}
if card_equipped_attire_id(plant_id) != -1{
	var spr_list = get_attire_info(card_equipped_attire_id(plant_id)).spr
	sprite_index = spr_list[shape]
}

// ========== 特定属性默认值 ==========

if global.level_file.level_time_feature == "daytime" && shape < 2{
	state = CARD_STATE.SLEEP
	if card_equipped_attire_id(plant_id) == -1{
		if shape == 0{
			sprite_index = spr_rotating_coffee_pot_sleep
		}
		else{
			sprite_index = spr_rotating_coffee_pot_sleep_1
		}
	}
}

attack_anim = 13;
idle_anim = 10
if shape == 0{
	idle_anim = 18
}
flash_speed = 5
plant_type = "normal"
is_slowdown = false
target_type = "rotate"

anim_timer = 0
awake_anim = 6
wake_timer = 0

if card_equipped_attire_id(plant_id) == "rotate_leo"{
	idle_anim = 10
	attack_anim = 14
	awake_anim = 0
}