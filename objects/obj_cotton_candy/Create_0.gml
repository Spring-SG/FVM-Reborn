event_inherited();  // 继承父对象属性
plant_id = "cotton_candy"; 
// 设置对象类型和精灵
obj_type = object_index;


is_derivative = false
on_lava = false


event_user(0)

// ========== 特定属性默认值 ==========
attack_anim = 0;
flash_speed = 8
idle_anim = 8
plant_type = "coffee"
spr_list = []
hole_count = 1
if shape == 0{
	sprite_index = spr_cotton_candy_0_0
	spr_list = [spr_cotton_candy_0_0,spr_cotton_candy_0_1,spr_cotton_candy_0_2]
}
else if shape == 1{
	sprite_index = spr_cotton_candy_1_0
	spr_list = [spr_cotton_candy_1_0,spr_cotton_candy_1_1,spr_cotton_candy_1_2]
}
else if shape == 2{
	sprite_index = spr_cotton_candy_2_0
	spr_list = [spr_cotton_candy_2_0,spr_cotton_candy_2_1,spr_cotton_candy_2_2]
	hole_count = 3
}