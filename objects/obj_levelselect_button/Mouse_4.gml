if on_click && obj_player_info_ui.menu_type == 0 && unlock{
	pressed = true
    global.audio.play(snd_button, 0, 0);
	texture_prefetch("cards")
	if target_level_id == "tower_cake"{
		global.gui_stack.to(room_tower_cake)
	}
	else if target_level_id == "camp_shop"{
		instance_create_depth(room_width/2,room_height/2,-5,obj_camp_shop_bg)
		obj_player_info_ui.menu_type = 4
		obj_world_map_button.world_map = 2
	}
	else if target_level_id == "camp_port"{
		instance_create_depth(room_width/2,room_height/2,-5,obj_camp_port_menu)
		obj_player_info_ui.menu_type = 4
		obj_world_map_button.world_map = 2
	}
	else{
	    global.gui_stack.to(room_ready)
	
		// 这是文件在 datafiles 目录下的相对路径
		global.level_id = target_level_id;
		var _file_path = "level_data/" + target_level_file; 
		if global.difficulty >= 2{
			_file_path = "level_data/" + target_level_file_hard; 
		}


		//使用 load_buffer 和 buffer_read 加载文件内容
		var _buffer = buffer_load(_file_path);
		if (!buffer_exists(_buffer)) {
		    show_debug_message("错误：无法加载关卡文件到缓冲区: " + _file_path);
		} else {
		    var _json_string = buffer_read(_buffer, buffer_string);
		    buffer_delete(_buffer); // 释放缓冲区内存

		    // 解析JSON字符串
		    global.level_file = json_parse(_json_string);
    
		    // 检查解析是否成功
		    if (global.level_file == -1) {
		        show_debug_message("错误：JSON 解析失败！");
		    } else {
		        show_debug_message("关卡文件加载并解析成功！");
		        show_debug_message(global.level_file);
		    }
		}
		var map_button_array = struct_get(ds_map_find_value(global.maps_map,global.map_id),"levels_data")
		global.level_data = map_button_array[level_index]
		show_debug_message(global.level_data)
	}
}
if !unlock && obj_player_info_ui.menu_type == 0{
	if player_level_require > 80{
		show_notice("暂未开放，敬请期待！",60)
	}
	else{
		if global.save_data.player.level < player_level_require{
			show_notice("达到"+string(player_level_require)+"级以解锁此关",60)
		}
		else{
			show_notice("完成前置关卡以解锁此关",60)
		}
	}
}





