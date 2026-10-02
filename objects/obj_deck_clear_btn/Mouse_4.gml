if !obj_readyroom_manager.is_submenu_open{
	global.audio.play(snd_button,0,0)
	clear_deck()
	obj_readyroom_manager.deck_first_slot_index = 0   // 清空后回到第一页
}