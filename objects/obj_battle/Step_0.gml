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
		instance_create_depth(enemy_pos.x-80,enemy_pos.y+33,-200,obj_hot_vajra)
		boss_count++
		//var grid_pos = get_grid_position_from_world(mouse_x,mouse_y)
		//var inst = instance_create_depth(grid_pos.x,grid_pos.y+38,0,obj_mario_mouse)
		//inst.grid_row = grid_pos.row
		//inst.grid_col = grid_pos.col
		//inst.frozen_timer = 0000
	}
	if keyboard_check_pressed(ord("L")){
		var grid_pos = get_grid_position_from_world(mouse_x,mouse_y)
		var inst = instance_create_depth(grid_pos.x,grid_pos.y+38,0,obj_machine_football_fan_mouse)
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
		var inst = instance_create_depth(grid_pos.x,grid_pos.y+38,0,obj_machine_skateboard_mouse)
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
		global.is_paused = true
		global.game_over = true
		instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
		audio_play_sound(snd_lose,0,0)
	}
}


if keyboard_check_pressed(vk_shift) || keyboard_check_pressed(vk_lshift){
	speed_up = not speed_up
	if speed_up{
		game_set_speed(120,gamespeed_fps)
	}
	else{
		game_set_speed(60,gamespeed_fps)
	}
}

if battle_time >= (global.level_file.first_wave_delay * 60) && level_stage == "ready" {
    
    level_stage = "pre"
    audio_play_sound(snd_mouse_wave_attack, 0, 0)
    
    enemy_subwave_summon()
    
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
	}
	else{
		current_subwave = 0
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