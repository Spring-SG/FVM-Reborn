if not obj_tower_cake_bg.is_submenu_opened{
	audio_play_sound(snd_button,0,0)
	global.gui_stack.pop()
	global.menu_screen = true
}