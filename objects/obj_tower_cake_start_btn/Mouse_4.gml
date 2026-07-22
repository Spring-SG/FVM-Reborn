if not obj_tower_cake_bg.is_submenu_opened{
	if obj_tower_cake_bg.level_select != -1{
		global.map_id = "tower_cake"
		global.map_name = "魔塔蛋糕"
		global.gui_stack.to(room_ready)
		if (global.network.mode == "server") {
		var _ld_send = variable_clone(global.level_data);
		var _rev = global._audio_reverse;
		var _mf = ["pre_music", "elite_music", "boss_music"];
		for (var _fi = 0; _fi < 3; _fi++) {
			var _f = _mf[_fi];
			var _v = _ld_send[$ _f];
			if (!is_string(_v) && ds_map_exists(_rev, _v)) {
				_ld_send[$ _f] = _rev[? _v];
			}
		}
			var _json = json_stringify({
				target_level_id: global.level_id,
				level_index: obj_tower_cake_bg.real_level_index,
				map_id: "tower_cake",
				level_data: _ld_send,
				level_file: global.level_file
			});
			
			var _list = global.network.connected_clients;
			for (var _i = 0; _i < array_length(_list); _i++) {
				send_message(_list[_i], MSG_ENTER_ROOM_READY, _json);
			}
		}
	}
	audio_play_sound(snd_button,0,0)
}