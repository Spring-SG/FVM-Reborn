if cooldown_timer <= 0{
	if (global.network.mode == "client") {
		send_message(global.network.server_socket, MSG_ACTIVE_SKILL_REQUEST, gem_id, obj_player_character.grid_col, obj_player_character.grid_row, gem_level);
		audio_play_sound(snd_button,0,0)
		cooldown_timer = cooldown
		return;
	}
	audio_play_sound(snd_button,0,0)
	
	var text = instance_create_depth(room_width/2+80,room_height/3-100,-500,obj_gem_text)
	text.sprite_index = spr_bomb_gem_text
	
	for(var i = 0 ; i < array_length(inst_pos_col);i++){
		var inst_pos = get_world_position_from_grid(inst_pos_col[i],inst_pos_row[i])
		var inst = instance_create_depth(inst_pos.x,inst_pos.y+30,-500,obj_bomb_gem_effect)
		inst.grid_row = inst_pos_row[i]
	}
	
	if (global.network.mode == "server") { network_broadcast_active_skill(gem_id, obj_player_character.grid_col, obj_player_character.grid_row, gem_level); }
	cooldown_timer = cooldown
}