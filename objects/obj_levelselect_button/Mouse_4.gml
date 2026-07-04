if on_click && obj_player_info_ui.menu_type == 0 && unlock{
	pressed = true
    audio_play_sound(snd_button, 0, 0);
	texture_prefetch("cards")
	if target_level_id != "tower_cake"{
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
		global.level_data_index = level_index
		show_debug_message(global.level_data)
		
		if(global.network.mode == "server"){
			var json_struct = {
			    "target_level_id":target_level_id,
			    "target_level_file": target_level_file,
			    "target_level_file_hard": target_level_file_hard,
			    "level_index": level_index,
				"map_id":global.map_id
			};
			
			var json_str = json_stringify(json_struct);
			var _list = global.network.connected_clients;
			var _size = array_length(_list);
			for (var i = 0; i < _size; i++) {
				var _socket = _list[i];
				send_message(_socket, MSG_ENTER_ROOM_READY,json_str);
			}
		}
		
	}
	else{
		global.gui_stack.to(room_tower_cake)
	}
}
if !unlock && obj_player_info_ui.menu_type == 0{
	if player_level_require > 80{
		show_notice("暂未开放，敬请期待！",60)
	}
	else{
		show_notice("达到"+string(player_level_require)+"级以解锁此关",60)
	}
}





