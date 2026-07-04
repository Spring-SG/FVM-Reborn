if not obj_tower_cake_bg.is_submenu_opened{
	if obj_tower_cake_bg.level_select != -1{
		global.map_id = "tower_cake"
		global.map_name = "魔塔蛋糕"
		global.gui_stack.to(room_ready)
		if (global.network.mode == "server") {
			var _json = json_stringify({
				target_level_id: global.level_id,
				level_index: obj_tower_cake_bg.real_level_index,
				map_id: "tower_cake",
				level_data: global.level_data,
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