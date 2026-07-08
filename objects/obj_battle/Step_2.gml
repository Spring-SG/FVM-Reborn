// 客户端：帧末清理boss产物临时实例(等服务端MSG_EVENT_ACTIONS同步)
if (global.network.mode == "client") {
	global.network.client_able = true;
	for (var _i = 0; _i < array_length(global._boss_client_cleanup); _i++) {
		var _inst = global._boss_client_cleanup[_i];
		if (instance_exists(_inst)) instance_destroy(_inst);
	}
	global._boss_client_cleanup = [];
	// 清理孤儿hpbar(boss已销毁但hpbar未清理)
	with (obj_boss_hpbar) {
	    if (!instance_exists(target_boss)) instance_destroy();
	}
	global.network.client_able = false;
}


for (var _i = 0; _i < array_length(global._move_insance_pre_arr); _i++) {
    var _inst = global._move_insance_pre_arr[_i];
    with (_inst) {
        // 判断是否拥有 parent_plant 或 parent_player 变量，且它们的值（对象索引）继承自 obj_card_parent
        var _hasPlant = variable_instance_exists(id, "parent_plant")  && object_is_ancestor(parent_plant.object_index, obj_card_parent);
        var _hasPlayer = variable_instance_exists(id, "parent_player") && object_is_ancestor(parent_player.object_index, obj_card_parent);
        if (_hasPlant || _hasPlayer) {
			if(!object_is_ancestor(object_index,obj_card_parent))
	            array_push(global._move_insance_arr, id); 
        }
    }
}

global._move_insance_pre_arr = [];


	



current_wave_hp = 0
with obj_enemy_parent{
	if target_type != "obstacle"{
		other.current_wave_hp += hp
	}
}
var c_min_time = wave_min_time
if is_real(global.level_file.version){
	if global.level_file.version >= 1.3{
		if current_wave < total_wave{
			var current_total_subwaves = array_length(global.level_file.waves[current_wave].subwaves)
			if current_subwave < current_total_subwaves{
				if global.level_file.waves[current_wave].subwaves[current_subwave].local_min_wave_time >0{
					c_min_time = global.level_file.waves[current_wave].subwaves[current_subwave].local_min_wave_time
				}
			}
		}
		
	}
}
if current_wave_hp <= hp_ratio * current_total_hp && level_stage != "boss"{
	if wave_timer < wave_max_time - c_min_time && wave_timer > 30{
		wave_timer = 30
	}
}
if not global.is_paused{
	wave_timer --
}
if (!global.save_data.unlocked_items.elite_unlocked && current_wave >= global.level_file.elite_wave)||current_wave >= global.level_file.total_waves{
	if current_wave_hp <= 0 && !instance_exists(obj_game_over){
		if global.network.mode == "server"{
			var _clients = global.network.connected_clients;
		    for (var i = 0; i < array_length(_clients); i++) {
		        send_message(_clients[i], MSG_GAME_OVER, 1);
		    }
		}
		if global.network.mode != "client"{
		global.is_paused = true
		global.game_over = true
		var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
		inst.sprite_index = spr_win
		audio_play_sound(snd_win,0,0)
		}
	}
}