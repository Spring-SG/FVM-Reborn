// 菜单栏按钮：菜单房 / 地图房 / 备战房间（room_ready）共用。
// 备战房间没有 obj_player_info_ui、obj_world_map_button，所以菜单状态的读写一律走
// scripts/menu_ui 里的函数，不要直接点对象名 —— 那样在备战房间会崩。
if !menu_ui_busy(){   // 等价于原来的 obj_player_info_ui.menu_type == 0，且顺带挡住「页面已经开着」
	global.audio.play(snd_button,0,0)
	texture_prefetch("cards")
	if target_screen == "quit"{//退出按钮
		if room == room_map{
			global.gui_stack.pop()
		}
		else{
			if not instance_exists(obj_quit_confirm){
				instance_create_depth(0,0,-20,obj_quit_confirm)
				menu_ui_set_type(4)
				menu_ui_set_world_map(2)
			}
		}
	}
	else if target_screen == "package"{
		instance_create_depth(1380,room_height/2,-15,obj_package_bg)
		menu_ui_set_type(4)
		menu_ui_set_world_map(2)
	}
	else if target_screen == "info"{
		instance_create_depth(1380,room_height/2,-15,obj_info_island_bg)
		menu_ui_set_type(4)
		menu_ui_set_world_map(2)
	}
	else if target_screen == "shop"{
		instance_create_depth(room_width/2,room_height/2,-15,obj_shop_bg)
		menu_ui_set_type(4)
		menu_ui_set_world_map(2)
	}
	else if target_screen == "craft"{
		instance_create_depth(room_width/2,room_height/2,-15,obj_craft_bg)
		menu_ui_set_type(4)
		menu_ui_set_world_map(2)
	}
	else if target_screen == "task"{
		instance_create_depth(room_width/2,room_height/2,-15,obj_task_bg)
		menu_ui_set_type(4)
		menu_ui_set_world_map(2)
	}
	else if target_screen == "cookbook"{
		instance_create_depth(room_width/2,room_height/2,-15,obj_cookbook_bg)
		menu_ui_set_type(4)
		menu_ui_set_world_map(2)
	}
}