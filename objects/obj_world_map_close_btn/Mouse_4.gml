global.audio.play(snd_button,0,0)
panel_anim_close(obj_world_map_menu)      // 反向滑出 + 淡出，播完由 panel_anim_step 销毁
obj_world_map_button.world_map = 0
if instance_exists(obj_player_info_ui){
	obj_player_info_ui.menu_type = 0
}
instance_destroy()