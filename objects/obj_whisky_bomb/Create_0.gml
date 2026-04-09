event_inherited();  // 继承父对象属性
plant_id = "whisky_bomb"; 
// 设置对象类型和精灵
obj_type = object_index;
current_level = 1
event_user(0)
sprite_index = spr_whisky_bomb;
if shape == 1{
	sprite_index = spr_whisky_bomb_1
}
else if shape == 2{
	sprite_index = spr_whisky_bomb_2
}

// ========== 特定属性默认值 ==========

attack_anim = 7;

can_mouse_list = ["can_mouse"]

idle_anim = 7
flash_speed = 5
plant_type = "normal"
invincible = true
if shape >= 1{
	atk*= 1.3
}