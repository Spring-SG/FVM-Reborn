if global.menu_screen{
	if world_map == 0 && !instance_exists(obj_world_map_menu) {   // 正在关闭时不重复创建
		if instance_exists(obj_player_info_ui){
			if obj_player_info_ui.menu_type != 0{
				exit
			}
		}
		global.audio.play(snd_button,0,0)
		world_map = 1
		instance_create_depth(room_width/2,room_height/2,-5,obj_world_map_menu)
		if instance_exists(obj_player_info_ui){
			obj_player_info_ui.menu_type = 3
		}
		image_index = 0
	}
}