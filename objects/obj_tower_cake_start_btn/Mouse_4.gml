if not obj_tower_cake_bg.is_submenu_opened{
	if obj_tower_cake_bg.level_select != -1{
		global.map_id = "tower_cake"
		global.map_name = "魔塔蛋糕"
		// room_goto(room_ready)
		global.gui_stack.to(room_ready)
	}
	audio_play_sound(snd_button,0,0)
}