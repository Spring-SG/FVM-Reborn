audio_play_sound(snd_button,0,0)
if btn_type == "cancel"{
	instance_destroy(obj_edit_menu)
	obj_player_info_ui.menu_type = 0
}
else if btn_type == "save"{
	with obj_edit_menu{
		event_user(0)
	}
	global.save_data.player.name = global.player_name
	instance_destroy(obj_edit_menu)
	obj_player_info_ui.menu_type = 0
}
else if btn_type == "open_save_folder"{
	var _user_profile = environment_get_variable("LOCALAPPDATA")
	var _target = global.laboratory_manager.file_util.transfer_path_to_windows( _user_profile + "\\FVM_Reborn\\saves")
	var ret = native_open_folder(_target)
	show_debug_message(ret)
}