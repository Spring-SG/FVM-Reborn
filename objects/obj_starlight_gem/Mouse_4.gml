if cooldown_timer <= 0{
	if (global.network.mode == "client") {
		send_message(global.network.server_socket, MSG_ACTIVE_SKILL_REQUEST, gem_id, obj_player_character.grid_col, obj_player_character.grid_row, gem_level);
		audio_play_sound(snd_button,0,0)
		cooldown_timer = cooldown
		return;
	}
	audio_play_sound(snd_button,0,0)

	var text = instance_create_depth(room_width/2+80,room_height/3-100,-500,obj_gem_text)
	text.sprite_index = spr_starlight_gem_text


	// 创建已选坐标数组
	var selected_coords = [];

	// 循环直到选出4个不同的坐标
	while (array_length(selected_coords) < star_amount) {
		// 生成随机坐标
		var rand_x = irandom_range(6, 8);
		var rand_y = irandom_range(0, global.grid_rows - 1);
		var new_coord = [rand_x, rand_y];

		// 检查是否已存在
		var exists = false;
		for (var i = 0; i < array_length(selected_coords); i++) {
			if (selected_coords[i][0] == new_coord[0] && selected_coords[i][1] == new_coord[1]) {
				exists = true;
				break;
			}
		}

		// 如果不存在则添加
		if (!exists) {
			array_push(selected_coords, new_coord);
		}
	}
	for (var i = 0 ; i < array_length(selected_coords);i++){
		var coord = selected_coords[i]
		var grid_pos = get_world_position_from_grid(coord[0],coord[1])
		var inst = instance_create_depth(grid_pos.x+8,grid_pos.y+10,-500,obj_starlight_gem_effect)
		inst.row = coord[1]
	}

	if (global.network.mode == "server") {
		network_broadcast_active_skill(gem_id, obj_player_character.grid_col, obj_player_character.grid_row, gem_level, json_stringify(selected_coords));
	}
	cooldown_timer = cooldown
}