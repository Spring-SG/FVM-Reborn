if global.is_paused{
	exit
}

if global.lose_focus_pause{
	if !window_has_focus() && !global.is_paused{
		global.is_paused = true
	}
}

battle_time ++
// obj_controller STEP 事件
if global.debug{
	if keyboard_check_pressed(ord("M")){
		var grid_pos = get_grid_position_from_world(mouse_x,mouse_y)
		var inst = instance_create_depth(grid_pos.x,grid_pos.y+38,0,obj_machine_flag_mouse)
		inst.grid_row = grid_pos.row
		inst.grid_col = grid_pos.col
		inst.frozen_timer = 0000
	}
	if keyboard_check_pressed(ord("N")){
		var enemy_row = irandom_range(0,global.grid_rows-1)
		var enemy_pos = get_world_position_from_grid(8,enemy_row)
		instance_create_depth(enemy_pos.x-80,enemy_pos.y+33,-200,obj_mouse_train_1_head)
		boss_count++
		//var grid_pos = get_grid_position_from_world(mouse_x,mouse_y)
		//var inst = instance_create_depth(grid_pos.x,grid_pos.y+38,0,obj_mario_mouse)
		//inst.grid_row = grid_pos.row
		//inst.grid_col = grid_pos.col
		//inst.frozen_timer = 0000
	}
	if keyboard_check_pressed(ord("L")){
		var grid_pos = get_grid_position_from_world(mouse_x,mouse_y)
		var inst = instance_create_depth(grid_pos.x,grid_pos.y+38,0,obj_trumpeter_mouse)
		inst.grid_row = grid_pos.row
		inst.grid_col = grid_pos.col
		inst.frozen_timer = 0000
	}
	if keyboard_check_pressed(ord("K")){
		var grid_pos = get_grid_position_from_world(mouse_x,mouse_y)
		var inst = instance_create_depth(grid_pos.x,grid_pos.y+38,0,obj_machine_iron_pan_mouse)
		inst.grid_row = grid_pos.row
		inst.grid_col = grid_pos.col
		inst.frozen_timer = 0000
	}
	if keyboard_check_pressed(ord("B")){
		var grid_pos = get_grid_position_from_world(mouse_x,mouse_y)
		var inst = instance_create_depth(grid_pos.x,grid_pos.y+38,0,obj_mirror_mouse)
		inst.grid_row = grid_pos.row
		inst.grid_col = grid_pos.col
		inst.frozen_timer = 0000
	}
	if keyboard_check_pressed(ord("J")){
		global.is_paused = true
		global.game_over = true
		var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
		inst.sprite_index = spr_win
		audio_play_sound(snd_win,0,0)
	}

	if keyboard_check_pressed(ord("R")){
		var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
		if (grid_pos.col >= 0 && grid_pos.col < global.grid_cols &&
			grid_pos.row >= 0 && grid_pos.row < global.grid_rows) {

			var new_plant = instance_create_depth(grid_pos.x, grid_pos.y, 0,obj_small_fire);
			var depth_value = calculate_plant_depth(grid_pos.col, grid_pos.row, new_plant.plant_type);
			card_created(new_plant, grid_pos.col, grid_pos.row);
			new_plant.depth = depth_value
			new_plant.flame_produce = 15000
			new_plant.ice_timer = 600
			instance_create_depth(grid_pos.x,grid_pos.y,-2,obj_place_effect)
			audio_play_sound(snd_place1,0,0)
		}
	}

	if keyboard_check_pressed(ord("A")){
		var grid_pos = get_grid_position_from_world(mouse_x, mouse_y);
		if (grid_pos.col >= 0 && grid_pos.col < global.grid_cols &&
			grid_pos.row >= 0 && grid_pos.row < global.grid_rows) {

			var new_plant = instance_create_depth(grid_pos.x, grid_pos.y, 0,obj_xiao_long_bao);
			var depth_value = calculate_plant_depth(grid_pos.col, grid_pos.row, new_plant.plant_type);
			card_created(new_plant, grid_pos.col, grid_pos.row);
			new_plant.depth = depth_value
			new_plant.atk = 90
			new_plant.ice_timer = 600
			new_plant.frozen_timer = 240
			instance_create_depth(grid_pos.x,grid_pos.y,-2,obj_place_effect)
			audio_play_sound(snd_place1,0,0)
		}
	}
}

//计时器逻辑
if global.level_file.time_limit != 0 && time_limit == -1{
	time_limit = global.level_file.time_limit * 60
}
if time_limit > 0{
	if !timer_pause{
		time_limit --
	}
	if time_limit <= 0{
		if global.network.mode == "server"{
			var _clients = global.network.connected_clients;
			for (var i = 0; i < array_length(_clients); i++) {
				send_message(_clients[i], MSG_GAME_OVER, 0);
			}
		}
		if global.network.mode != "client"{
			global.is_paused = true
			global.game_over = true
			instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
			audio_play_sound(snd_lose,0,0)
		}
	}
}



if keyboard_check_pressed(vk_shift) || keyboard_check_pressed(vk_lshift){
	if (global.network.mode == "server") {
		var _cl = global.network.connected_clients;
		for (var i = 0; i < array_length(_cl); i++) {
			send_message(_cl[i], MSG_SERVER_ACTION, speed_up ? 0 : 1);
		}
	}
	speed_up = not speed_up
	if speed_up{
		game_set_speed(120,gamespeed_fps)
	}
	else{
		game_set_speed(60,gamespeed_fps)
	}
}

// game over 后服务端快捷键
if (global.game_over && global.network.mode == "server") {
	if (keyboard_check_pressed(vk_space)) {
		var _cl = global.network.connected_clients;
		for (var i = 0; i < array_length(_cl); i++) {
			send_message(_cl[i], MSG_SERVER_ACTION, 4);
		}
		global.gui_stack.to(room_ready);
	}
	if (keyboard_check_pressed(ord("R"))) {
		var _cl = global.network.connected_clients;
		for (var i = 0; i < array_length(_cl); i++) {
			send_message(_cl[i], MSG_SERVER_ACTION, 5);
		}
		global.gui_stack.pop();
		room_goto(room_battle);
	}
}

if speed_up{
	game_set_speed(120,gamespeed_fps)
}
else{
	game_set_speed(60,gamespeed_fps)
}



if (global.network.mode!="client"){


if battle_time >= (global.level_file.first_wave_delay * 60) && level_stage == "ready" {

	level_stage = "pre"
	audio_play_sound(snd_mouse_wave_attack, 0, 0)

	enemy_subwave_summon()
	
	// 服务端同步进度条
	if (global.network.mode == "server") {
		var _cl = global.network.connected_clients;
		for (var _j = 0; _j < array_length(_cl); _j++) {
			send_message(_cl[_j], MSG_PROGRESS_SYNC, current_wave, current_subwave);
		}
	}

	current_subwave += 1;
}
var current_total_subwaves = 0
var wave_data = {}
if current_wave < total_wave{
	current_total_subwaves = array_length(global.level_file.waves[current_wave].subwaves)
	wave_data = global.level_file.waves[current_wave]
}
else{
	current_total_subwaves = array_length(global.level_file.waves[current_wave-1].subwaves)
	wave_data = global.level_file.waves[current_wave-1]
}

if wave_data.boss_wave && level_stage != "boss" && global.save_data.unlocked_items.elite_unlocked && wave_timer == 1{
	level_stage = "boss"
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = get_world_position_from_grid(10,enemy_row)
	var boss_inst = instance_create_depth(enemy_pos.x-80,enemy_pos.y+30,-200,global.enemy_map[? wave_data.boss]._obj)
	boss_count ++
	if is_real(global.level_file.version){
		boss_inst.hp *= wave_data.boss_1_hp_modify
		boss_inst.maxhp *= wave_data.boss_1_hp_modify
		if wave_data.boss2 != ""{
			var enemy_row_2 = irandom_range(0,global.grid_rows-1)
			var enemy_pos_2 = get_world_position_from_grid(10,enemy_row_2)
			var boss_2_inst = instance_create_depth(enemy_pos_2.x-80,enemy_pos_2.y+30,-200,global.enemy_map[? wave_data.boss2]._obj)
			boss_2_inst.hp *= wave_data.boss_2_hp_modify
			boss_2_inst.maxhp *= wave_data.boss_2_hp_modify
			boss_count ++
		}
	}
	with obj_battle_music_controller{
		new_battle_music = global.level_data.boss_music
		event_user(0)
	}
	// 服务端同步boss音乐给客户端
	if (global.network.mode == "server") {
		var _cl = global.network.connected_clients;
		for (var _j = 0; _j < array_length(_cl); _j++) {
			send_message(_cl[_j], MSG_MUSIC_SYNC, global.level_data.boss_music);
		}
	}

	// 服务端广播boss生成给所有客户端
	if (global.network.mode == "server") {
		add_net_id(boss_inst.id);
		var _boss1_net = global.network.map_instance_id_net_id[? boss_inst.id];
		if (is_real(global.level_file.version) && wave_data.boss2 != "") {
			add_net_id(boss_2_inst.id);
			var _boss2_net = global.network.map_instance_id_net_id[? boss_2_inst.id];
		}
		var _list = global.network.connected_clients;
		var _size = array_length(_list);
		for (var _i = 0; _i < _size; _i++) {
			var _socket = _list[_i];
			send_message(_socket, MSG_SPAWN_BOSS, _boss1_net, enemy_pos.x-80, enemy_pos.y+30, object_get_name(global.enemy_map[? wave_data.boss]._obj), boss_inst.hp, boss_inst.maxhp, enemy_row);
		}
		if (is_real(global.level_file.version) && wave_data.boss2 != "") {
			for (var _i = 0; _i < _size; _i++) {
				var _socket = _list[_i];
				send_message(_socket, MSG_SPAWN_BOSS, _boss2_net, enemy_pos_2.x-80, enemy_pos_2.y+30, object_get_name(global.enemy_map[? wave_data.boss2]._obj), boss_2_inst.hp, boss_2_inst.maxhp, enemy_row_2);
			}
		}
	}
}
if wave_timer <= 0 && level_stage == "pre"{
	if(global.save_data.unlocked_items.elite_unlocked) || !global.save_data.unlocked_items.elite_unlocked && current_wave < global.level_file.elite_wave{
		if current_wave < total_wave{
			enemy_subwave_summon()
		}
		if current_subwave < current_total_subwaves-1{
			current_subwave+=1
		}
		else if current_wave < total_wave{
			current_wave += 1
			if (global.network.mode == "server") {
				var _cl = global.network.connected_clients;
				for (var _j = 0; _j < array_length(_cl); _j++) {
					send_message(_cl[_j], MSG_PROGRESS_SYNC, current_wave, current_subwave);
				}
			}
			current_subwave = 0
			audio_play_sound(snd_mouse_wave_attack,0,0)
			instance_create_depth(room_width/2,room_height/2,-300,obj_huge_wave_text)
		}
	}
}
if wave_timer <= 0 && level_stage == "boss"{
	enemy_subwave_summon()
	if current_subwave < current_total_subwaves-1{
		current_subwave+=1
		
		//  服务端同步消息
		if (global.network.mode == "server") {
			var _cl = global.network.connected_clients;
			for (var _j = 0; _j < array_length(_cl); _j++) {
				send_message(_cl[_j], MSG_PROGRESS_SYNC, current_wave, current_subwave);
			}
		}
	}
	else{
		current_subwave = 0
	}
}

// 服务端每60步同步一次 HP 和位置
if (global.network.mode == "server" && battle_time mod 60 == 0) {
	var _list = global.network.connected_clients;
	var _size = array_length(_list);

	with (obj_enemy_parent) {
		if (hp > 0 && state != ENEMY_STATE.DEAD) {
			var _net_id = (ds_map_exists(global.network.map_instance_id_net_id, id)) ? global.network.map_instance_id_net_id[? id] : -1;
			if (_net_id != -1) {
				for (var _i = 0; _i < _size; _i++) {
					send_message(_list[_i], MSG_ENEMY_HP, _net_id, hp, maxhp);
					send_message(_list[_i], MSG_ENEMY_CALIBRATE, _net_id, x, y);
				}
			}
		}
	}

	with (obj_card_parent) {
		if (hp > 0) {
			var _net_id = (ds_map_exists(global.network.map_instance_id_net_id, id)) ? global.network.map_instance_id_net_id[? id] : -1;
			if (_net_id != -1) {
				for (var _i = 0; _i < _size; _i++) {
					send_message(_list[_i], MSG_UNIT_HP, _net_id, hp, max_hp);
				}
			}
		}
	}
}


if global.debug{
	if keyboard_check_pressed(ord("V")){
		if level_stage == "ready"{
			battle_time = (global.level_file.first_wave_delay * 60)
		}
		if current_subwave < current_total_subwaves{
			current_subwave+=1
		}
		else if current_wave == total_wave-1{
			global.is_paused = true
			global.game_over = true
			var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
			inst.sprite_index = spr_win
			audio_play_sound(snd_win,0,0)
		}
		else if current_wave < total_wave{
			current_wave += 1
			current_subwave = 0
		}
	}
}
}



