global.audio.play(snd_button,0,0)
if btn_type == "cancel"{
	panel_anim_close(obj_edit_menu)
	obj_player_info_ui.menu_type = 0
}
else if btn_type == "save"{
	with obj_edit_menu{
		event_user(0)
	}
	global.save_data.player.name = global.player_name
	panel_anim_close(obj_edit_menu)
	obj_player_info_ui.menu_type = 0
}
else if btn_type == "open_save_folder"{
	var _target = global.native_util.get_path_in_local_appdata("\\FVM_Reborn\\saves")
	var ret = native_open_folder(_target)
	if (ret != 0) {
		global.native_util.show_error(ret, "打开存档文件夹失败")
	}
}
else if btn_type == "export_save_backup" {
	var _saves_target = global.native_util.get_path_in_local_appdata("\\FVM_Reborn\\saves")
	var ret = native_start_backup(_saves_target)
	if (ret != 0 && ret != -3) {
		global.native_util.show_error(ret, "导出存档备份失败")
	} else {
        show_message_async("存档已导出")
	}
}
else if btn_type == "import_save_backup" {
	var _saves_target = global.native_util.get_path_in_local_appdata("\\FVM_Reborn\\saves")
	var _backup_target = global.native_util.get_path_in_local_appdata("\\FVM_Reborn\\backups")
	var ret = native_restore_backup(_saves_target, _backup_target)
	if (ret != 0 && ret != -3) {
		global.native_util.show_error(ret, "导入存档备份失败")
	} else {
		load_file(global.save_slot)
        show_message_async("导入存档成功")
	}
}
