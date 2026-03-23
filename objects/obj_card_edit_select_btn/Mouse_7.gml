audio_play_sound(snd_button,0,0)
if btn_type == "confirm"{
	var card_id = global.player_deck[| obj_card_edit_menu.target_card_index*2];
	var length = array_length(global.save_data.unlocked_cards)
	var info_index = 0
	for (var i = 0;i < length;i++){
		if global.save_data.unlocked_cards[i].id == card_id{
			info_index = i
			break
		}
	}
	var egg = irandom_range(1,100)
	if egg <= 2{
		if global.save_data.unlocked_cards[info_index].level > 5{
			global.save_data.unlocked_cards[info_index].level -= 1
			
			
		}
		show_notice("不够好运，升级失败！",60)
	}
	else {
		global.save_data.unlocked_cards[info_index].level = obj_card_edit_menu.target_current_info[? "level"]
		global.save_data.unlocked_cards[info_index].shape = obj_card_edit_menu.target_current_info[? "shape"]
		global.save_data.unlocked_cards[info_index].skill = obj_card_edit_menu.target_current_info[? "skill"]
	}
	
	
	save_file(global.save_slot)
}
else if btn_type == "apply"{
	var length = array_length(global.save_data.unlocked_cards)
	var info_index = 0
	var egg = irandom_range(1,100)
	if egg <= 2{
		for (var i = 0;i < length;i++){
			if global.save_data.unlocked_cards[i].level>5{
				global.save_data.unlocked_cards[i].level -= 1
			}
		}
		show_notice("不够好运，升级失败！",60)
	}
	else{
		for (var i = 0;i < length;i++){
			var card_id = global.save_data.unlocked_cards[i].id
			if obj_card_edit_menu.target_current_info[? "level"] <= get_card_info_simple(card_id).max_level{
				global.save_data.unlocked_cards[i].level = obj_card_edit_menu.target_current_info[? "level"]
			}
			else{
				global.save_data.unlocked_cards[i].level = get_card_info_simple(card_id).max_level
			}
			global.save_data.unlocked_cards[i].skill = obj_card_edit_menu.target_current_info[? "skill"]
			if obj_card_edit_menu.target_current_info[? "shape"] <= get_card_info_simple(card_id).max_shape{
				global.save_data.unlocked_cards[i].shape = obj_card_edit_menu.target_current_info[? "shape"]
			}
			else{
				global.save_data.unlocked_cards[i].shape = get_card_info_simple(card_id).max_shape
			}
		}
	}
	
	
	save_file(global.save_slot)
}
obj_package_bg.is_submenu_opened = false
instance_destroy(obj_card_edit_menu)