if obj_readyroom_manager.selected_custom_deck != 0 && !obj_readyroom_manager.is_submenu_open{
	global.audio.play(snd_button,0,0)
	save_to_custom_deck(obj_readyroom_manager.selected_custom_deck-1,"卡组"+string(obj_readyroom_manager.selected_custom_deck))
	show_notice("卡组已保存",60)
}