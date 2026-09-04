

if not obj_tower_cake_bg.is_submenu_opened{
	var level_list = global.maps_map[? "tower_cake"].levels_data
	global.level_data = level_list[level_index]

	global.level_id = global.level_data.id
	var _file_path = "level_data/" + global.level_data.level_file
	if global.difficulty >= 2{
		_file_path = "level_data/" + global.level_data.hard_level_file
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
	        //show_debug_message(global.level_file);
	    }
	}
	if obj_tower_cake_bg.level_select != btn_index{
		obj_tower_cake_bg.level_select = btn_index
		obj_tower_cake_bg.real_level_index = level_index
		audio_play_sound(snd_button,0,0)
		with obj_tower_cake_bg{
			refresh_reward_button()
		}
	}
	obj_tower_cake_start_btn.is_unlocked = is_unlocked
}
