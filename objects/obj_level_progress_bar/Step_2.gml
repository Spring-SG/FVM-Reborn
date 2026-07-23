if global.is_paused{
	exit
}


if obj_battle.current_wave >= elite_wave && obj_battle.wave_timer <= 1{
	if global.save_data.unlocked_items.elite_unlocked{
		level_stage = "elite"
		// 客户端不本地切换音乐，只通过服务端 MSG_MUSIC_SYNC 同步
		if (global.network.mode != "client") {
			if obj_battle_music_controller.battle_music != global.level_data.elite_music && obj_battle.level_stage != "boss"{
				with obj_battle_music_controller{
					new_battle_music = global.level_data.elite_music
					event_user(0)
				}
				// 服务端同步精英音乐给客户端
				if (global.network.mode == "server") {
					var _cl = global.network.connected_clients;
					for (var _j = 0; _j < array_length(_cl); _j++) {
						send_message(_cl[_j], MSG_MUSIC_SYNC, 1);
					}
				}
			}
		}
	}
	else{
		//global.is_paused = true
		//global.game_over = true
		//var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
		//inst.sprite_index = spr_win
		//audio_play_sound(snd_win,0,0)
	}
}