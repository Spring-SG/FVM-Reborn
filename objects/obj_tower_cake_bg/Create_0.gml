image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

instance_create_depth(x+810,y-472,depth-1,obj_closetowercake_btn)

is_submenu_opened = false
current_page = 1
total_page = 3
level_select = -1
real_level_index = -1

reward_button_list = []
level_button_list = []

map_surface = -1

var page_btn1 = instance_create_depth(x-695,y+495,depth-1,obj_tower_cake_page_btn)
page_btn1.sprite_index = spr_tower_cake_page_btn
page_btn1.btn_type = "prev"
var page_btn2 = instance_create_depth(x-605,y+495,depth-1,obj_tower_cake_page_btn)
page_btn2.sprite_index = spr_tower_cake_page_btn
page_btn2.btn_type = "next"
var page_btn3 = instance_create_depth(x-750,y+495,depth-1,obj_tower_cake_page_btn)
page_btn3.sprite_index = spr_tower_cake_page_set_btn
page_btn3.btn_type = "min"
var page_btn4 = instance_create_depth(x-550,y+495,depth-1,obj_tower_cake_page_btn)
page_btn4.sprite_index = spr_tower_cake_page_set_btn
page_btn4.btn_type = "max"

instance_create_depth(x+608,y+470,depth-1,obj_tower_cake_start_btn)
refresh_level_button()
//for(var i = 0 ; i < 15 ; i ++){
//	instance_create_depth(x-648,y+438-56*i,depth-1,obj_tower_cake_level_btn)
//}

//var inst = instance_create_depth(x+608,y-280,depth-2,obj_tower_cake_card_reward)
//inst.target_card_id = "small_fire"
//inst.target_shape = 1
//inst.unlocked = true
//var inst2 = instance_create_depth(x+744,y-280,depth-3,obj_tower_cake_card_reward)
//inst2.target_card_id = "gatlin_long_bao"
//inst2.target_shape = 1
//inst2.unlocked = true
//var inst3 = instance_create_depth(x+472,y-280,depth-1,obj_tower_cake_card_reward)
//inst3.target_card_id = "goblet_lamp"
//inst3.target_shape = 1
//inst3.unlocked = true

function refresh_level_button(){
	instance_destroy(obj_tower_cake_level_btn)
	var level_list = global.maps_map[? "tower_cake"].levels_data
	for(var i = 0 ;i < 15;i++){
		var level_index = i + 15 * (current_page - 1)
		if level_index < array_length(level_list){
			var c_level_data = level_list[level_index]
			var inst = instance_create_depth(x-648,y+438-56*i,depth-1,obj_tower_cake_level_btn)
			inst.btn_index = i
			inst.level_index = level_index
			inst.btn_text = string((level_index div 2) + 1) + "-" + string((level_index mod 2) + 1)
		
			if (array_get_index(global.save_data.completed_levels,c_level_data.pre_level) != -1) || c_level_data.pre_level == "none"{
				inst.is_unlocked = true
			}
		}
		else{
			break
		}
	}
}

function refresh_reward_button(){
	instance_destroy(obj_tower_cake_card_reward)
	var level_list = global.maps_map[? "tower_cake"].levels_data
	var c_level_data = level_list[real_level_index]
	for(var i = 0 ; i < array_length(c_level_data.rewards);i++){
		var inst = instance_create_depth(x+472+136*i,y-280,depth-i-1,obj_tower_cake_card_reward)
		inst.target_card_id = c_level_data.rewards[i].card_id
		inst.target_shape = c_level_data.rewards[i].target_shape
		inst.btn_index = i + 1
		
		if (array_get_index(global.save_data.completed_levels,c_level_data.id) != -1){
			inst.unlocked = true
		}
	}
}