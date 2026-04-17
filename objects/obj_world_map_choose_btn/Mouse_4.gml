if unlocked{
	audio_play_sound(snd_button,0,0)
	obj_world_map_button.world_map = 0
	instance_destroy(obj_world_map_menu)
	texture_prefetch("enemy_delicious")
	texture_prefetch("enemy_volcanic")
	texture_prefetch("enemy_tower")
	if map_id != "tower_cake"{
		if global.map_id != map_id{
			global.map_name = map_name
			global.map_id = map_id
		}
		if room != room_target{
			// room_goto(room_target)
			global.gui_stack.to(room_target)
		}
	}
	else{
		instance_destroy(obj_world_map_menu)
		instance_create_depth(room_width/2,room_height/2,-5,obj_tower_cake_bg)
		obj_player_info_ui.menu_type = 4
		obj_world_map_button.world_map = 2
	}
}
else{
	show_notice("达到"+string(level_require)+"级以解锁此地图",60)
}