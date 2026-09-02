if obj_cookbook_bg.button_select != btn_index{
	obj_cookbook_bg.button_select = btn_index
	with obj_cookbook_bg{
		target_cookbook_index = -1
		refresh_cookbook_list()
		y_offset = 0
	}
	audio_play_sound(snd_button,0,0)
}