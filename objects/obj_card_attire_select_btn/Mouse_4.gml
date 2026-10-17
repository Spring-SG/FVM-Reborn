obj_card_attire_menu.sw_pending_dir = (type == "prev") ? -1 : 1   // 方向以按下的箭头为准
if type == "prev"{
	if obj_card_attire_menu.selected_attire_index > -1{
		obj_card_attire_menu.selected_attire_index -= 1
	}
	else{
		obj_card_attire_menu.selected_attire_index = array_length(obj_card_attire_menu.card_attire_id_list)-1
	}
}
else{
	if obj_card_attire_menu.selected_attire_index < array_length(obj_card_attire_menu.card_attire_id_list)-1{
		obj_card_attire_menu.selected_attire_index += 1
	}
	else{
		obj_card_attire_menu.selected_attire_index = -1
	}
}
global.audio.play(snd_button,0,0)