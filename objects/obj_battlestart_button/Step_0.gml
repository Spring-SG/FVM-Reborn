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

		}
	}
}