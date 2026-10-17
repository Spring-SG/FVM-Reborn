if obj_task_bg.button_select != btn_index{
	obj_task_bg.button_select = btn_index
	with obj_task_bg{
		target_task_index = -1
		refresh_task_list()

	}
	global.audio.play(snd_button,0,0)
}