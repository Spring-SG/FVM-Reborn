
if obj_player_info_ui.menu_type == 0{
	audio_play_sound(snd_button,0,0)
	texture_prefetch("cards")
	if target_screen == "quit"{//退出按钮
		if room == room_map{
			// room_goto(room_menu)
			global.gui_stack.pop()
		}
		else{
			if not instance_exists(obj_quit_confirm){
				instance_create_depth(0,0,-20,obj_quit_confirm)
				obj_player_info_ui.menu_type = 4
				obj_world_map_button.world_map = 2
			}
		}
	}
	else if target_screen == "package"{
		instance_create_depth(1380,room_height/2,-5,obj_package_bg)
		obj_player_info_ui.menu_type = 4
		obj_world_map_button.world_map = 2
	}
	else if target_screen == "info"{
		instance_create_depth(1380,room_height/2,-5,obj_info_island_bg)
		obj_player_info_ui.menu_type = 4
		obj_world_map_button.world_map = 2
	}
	else if target_screen == "shop"{
		instance_create_depth(room_width/2,room_height/2,-5,obj_shop_bg)
		obj_player_info_ui.menu_type = 4
		obj_world_map_button.world_map = 2
	}
	else if target_screen == "craft"{
		instance_create_depth(room_width/2,room_height/2,-5,obj_craft_bg)
		obj_player_info_ui.menu_type = 4
		obj_world_map_button.world_map = 2
	}
	else if target_screen == "task"{
		instance_create_depth(room_width/2,room_height/2,-5,obj_task_bg)
		obj_player_info_ui.menu_type = 4
		obj_world_map_button.world_map = 2
	} else if target_screen = "cookbook"{
		var _gui_result = global.gui_stack.to(room_laboratory)
		if (_gui_result.is_failed()) {
			show_message_async(_gui_result.message)
		}
	}
}
