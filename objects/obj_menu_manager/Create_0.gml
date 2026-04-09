depth = -1200

// 强制清除application_surface，避免上一房间图像残留
if surface_exists(application_surface){
	surface_set_target(application_surface);
	draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
	surface_reset_target();
}

instance_create_depth(1355,820,-2,obj_startgame_button)
instance_create_depth(100,0,-2,obj_player_info_ui)
if not instance_exists(obj_menu_music_controller){
	var mus_inst = instance_create_depth(0,0,0,obj_menu_music_controller)
	mus_inst.menu_music = mus_town
}
if not instance_exists(obj_world_map_button){
	instance_create_depth(1670,80,0,obj_world_map_button)
}
instance_create_depth(room_width-210,room_height,-1,obj_player_menu_bg)
timer = 0