if on_click{
	panel_anim_close(obj_config_menu)
	global.audio.play(snd_button,0,0)
	if global.menu_screen{
		obj_player_info_ui.menu_type = 0
	}
}