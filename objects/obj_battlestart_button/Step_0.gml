if button_pushed{
	timer ++
	if timer < 16{
		image_index = floor(timer / 4)
	}
	else{
		if global.network.mode =="client"{
			show_notice("等待房主操作",60);
			return;
		}
		audio_pause_sound(mus_readyroom)
		//global.gui_stack.to(room_battle)
		global.gui_stack.to(room_battle)
		texture_prefetch("bullet")
		texture_prefetch("effects")
		
		if global.network.mode =="server"{
			var _list = global.network.connected_clients;
			var _size = array_length(_list);
			for (var i = 0; i < _size; i++) {
				var _socket = _list[i];
				send_message(_socket, MSG_START_BATTLE);
			}
			ds_map_clear(global.network.map_instance_id_net_id)
			ds_map_clear(global.network.map_net_id_instance_id)
			global.network.net_instance_count=0
		}
		
		sprite_manager_load_async(["spr_small_fire"], global._sprite_cache);
		sprite_manager_load_battle(obj_readyroom_manager._get_needed_sprites())
		    // 从 _sprite_data 收集所有精灵名（跳过 _ 开头的元数据）
		/*
		var _sprite_list = [];
		var _data_keys = variable_struct_get_names(global._sprite_data);
		for (var i = 0; i < array_length(_data_keys); i++) {
		    var _k = _data_keys[i];
		    if (string_char_at(_k, 1) == "_") continue;  // 跳过 _project_root 等
		    array_push(_sprite_list, _k);
		}
		// 异步加载第一帧
		sprite_manager_load_async(_sprite_list, global._sprite_cache, false);
		*/
	}
}