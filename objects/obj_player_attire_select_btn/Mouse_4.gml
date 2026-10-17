obj_edit_menu.sw_pending_dir = (type == "prev") ? -1 : 1   // 方向以按下的箭头为准
if type == "prev"{
	if obj_edit_menu.selected_attire_index > -1{
		obj_edit_menu.selected_attire_index -= 1
	}
	else{
		obj_edit_menu.selected_attire_index = array_length(obj_edit_menu.player_attire_id_list)-1
	}
}
else{
	if obj_edit_menu.selected_attire_index < array_length(obj_edit_menu.player_attire_id_list)-1{
		obj_edit_menu.selected_attire_index += 1
	}
	else{
		obj_edit_menu.selected_attire_index = -1
	}
}
global.audio.play(snd_button,0,0)