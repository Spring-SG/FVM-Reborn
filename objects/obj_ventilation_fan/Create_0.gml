// obj_small_furnace 的 Create 事件
//plant_id = "small_fire";  // 唯一标识符
event_inherited();  // 继承父对象属性
plant_id = "ventilation_fan"; 
// 设置对象类型和精灵

event_user(0)
sprite_index = spr_ventilation_fan
if shape == 1{
	sprite_index = spr_ventilation_fan_1
}
else if shape == 2{
	sprite_index = spr_ventilation_fan_2
}
// ========== 特定属性默认值 ==========
if shape >= 1{
	hp *= 5
	max_hp *= 5
}
attack_anim = 26;
idle_anim = 12
flash_speed = 5
invincible = true
plant_type = "normal"
is_slowdown = false

effect_timer = 0

ignore_list = ["mario_mouse","mario_pipeline","arno","pharaoh_coffin","temple_pharaoh","ice_residue","rumble","abyss_pharaoh",
				"pink_paul","paul_tentacle","blonde_mary","pete","pete_claw","pete_spike","bat_mouse"
]
