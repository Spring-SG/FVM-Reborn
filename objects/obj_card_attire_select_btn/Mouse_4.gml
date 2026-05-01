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
audio_play_sound(snd_button,0,0)