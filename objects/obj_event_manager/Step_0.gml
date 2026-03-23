if global.is_paused{
	exit
}

event_timer ++

if global.level_data.name == "布丁岛（日）" || global.level_data.name == "布丁岛（夜）"{
	if event_timer mod 1800 == 5{
		//(测试)生成老鼠洞
		var can_summon = true
		for(var i = 0 ; i < 100;i++){
			can_summon = true
			var pos_x = irandom_range(4,global.grid_cols-1)
			var pos_y = irandom_range(0,global.grid_rows-1)
			var cave_pos = get_world_position_from_grid(pos_x,pos_y)
			var plant_list = ds_grid_get(global.grid_plants,cave_pos.col,cave_pos.row)
			with obj_mouse_hole{
				var pos1 = get_grid_position_from_world(x,y)
				if(pos1.row == cave_pos.row && pos1.col == cave_pos.col){
					can_summon = false
				}
			}
			if ds_list_size(plant_list)>0{
				can_summon = false
			}
			if can_summon{
				instance_create_depth(cave_pos.x,cave_pos.y,-5,obj_mouse_hole)
				break
			}
		}
	}
}

if global.level_data.name == "咖喱岛（日）" || global.level_data.name == "咖喱岛（夜）"{
	if event_timer == 1{
		for(var i = 0 ; i < global.grid_rows ; i++){
			for(var j = 6 ; j < global.grid_cols+3;j++){
				var pos = get_world_position_from_grid(j,i)
				var fog = instance_create_depth(pos.x+10,pos.y-50,-800,obj_fog)
				fog.col = j
				fog.row = i
			}
		}
	}
}

if global.level_data.name == "深渊岛" || global.level_data.name == "可可岛（夜）"{
	if event_timer mod 1800 == 5{
		var b_col = irandom_range(0,8)
		var b_row = irandom_range(0,6)
		var target_pos = get_world_position_from_grid(b_col,b_row) 
		var inst = instance_create_depth(target_pos.x+10,target_pos.y-room_height,-500,obj_bat_mouse_target)
		inst.target_col = b_col
		inst.target_row = b_row
		var bat = instance_create_depth(target_pos.x+10,target_pos.y-room_height,-500,obj_bat_mouse)
		bat.target_col = b_col
		bat.target_row = b_row
		bat.banding_target_inst = inst
	}
}

if global.level_id == "mustard_cottage_daytime" && event_timer == 1{
	var obs_pos = get_world_position_from_grid(6,5)
	var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
	inst.row = 5
}
if global.level_id == "mustard_cottage_night" && event_timer == 1{
	var obs_pos = get_world_position_from_grid(6,1)
	var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
	inst.row = 1
}
if global.level_id == "cheese_castle" && event_timer == 1{
	var obs_pos = get_world_position_from_grid(6,1)
	var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
	inst.row = 1
	var obs_pos2 = get_world_position_from_grid(6,5)
	var inst2 = instance_create_depth(obs_pos2.x,obs_pos2.y-35,-1200,obj_obstacle)
	inst2.row = 5
}
if global.level_id == "mint_beach_daytime" && event_timer == 1{
	var obs_pos = get_world_position_from_grid(5,0)
	var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
	inst.row = 0
	var obs_pos2 = get_world_position_from_grid(7,3)
	var inst2 = instance_create_depth(obs_pos2.x,obs_pos2.y-35,-1200,obj_obstacle)
	inst2.row = 3
	var obs_pos3 = get_world_position_from_grid(3,5)
	var inst3 = instance_create_depth(obs_pos3.x,obs_pos3.y-35,-1200,obj_obstacle)
	inst3.row = 5
}
if global.level_id == "mint_beach_night" && event_timer == 1{
	var obs_pos = get_world_position_from_grid(2,0)
	var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
	inst.row = 0
	var obs_pos2 = get_world_position_from_grid(1,3)
	var inst2 = instance_create_depth(obs_pos2.x,obs_pos2.y-35,-1200,obj_obstacle)
	inst2.row = 3
	var obs_pos3 = get_world_position_from_grid(8,3)
	var inst3 = instance_create_depth(obs_pos3.x,obs_pos3.y-35,-1200,obj_obstacle)
	inst3.row = 3
	var obs_pos4 = get_world_position_from_grid(5,6)
	var inst4 = instance_create_depth(obs_pos4.x,obs_pos4.y-35,-1200,obj_obstacle)
	inst4.row = 6
}

if (global.level_id == "mustard_cottage_daytime" || global.level_id == "mustard_cottage_night") && obj_battle.current_wave >= global.level_file.elite_wave && obj_battle.level_stage != "boss"{
	if event_timer mod 1800 == 5{
		var b_col = irandom_range(0,8)
		var b_row = irandom_range(0,6)
		var target_pos = get_world_position_from_grid(b_col,b_row) 
		var inst = instance_create_depth(target_pos.x,target_pos.y+38,-500,obj_pink_paul_tentacle)
	}
}

if global.level_id == "cheese_castle" && obj_battle.current_wave >= 2 && obj_battle.level_stage != "boss" && obj_battle.current_wave < global.level_file.elite_wave{
	if event_timer mod 1800 == 5{
		var b_col = irandom_range(0,8)
		var b_row = irandom_range(0,6)
		var target_pos = get_world_position_from_grid(b_col,b_row) 
		var inst = instance_create_depth(target_pos.x,target_pos.y+38,-500,obj_pink_paul_tentacle)
	}
}

if global.level_id == "cheese_castle" && obj_battle.current_wave == 6 && obj_battle.current_subwave == 0{
	cheese_castle_anim_timer++
	if cheese_castle_anim_timer == 1{
		var inst = instance_create_depth(0,0,49,obj_map_change_effect)
		inst.map_spr = spr_cheese_castle
		inst.map_spr_index = 0
		obj_battle.map_spr_index = 1
	}
	else if cheese_castle_anim_timer == 45{
		var inst = instance_create_depth(0,0,49,obj_map_change_effect)
		inst.map_spr = spr_cheese_castle
		inst.map_spr_index = 1
		obj_battle.map_spr_index = 2
	}
	else if cheese_castle_anim_timer == 90{
		var inst = instance_create_depth(0,0,49,obj_map_change_effect)
		inst.map_spr = spr_cheese_castle
		inst.map_spr_index = 2
		obj_battle.map_spr_index = 3
	}
	
	if obj_battle.map_spr_index != 3{
		
		for(var i = 0 ; i < global.grid_rows ; i++){
			for(var j = 0 ; j < global.grid_cols ; j++){
				if global.grid_terrains[i][j].type == "water"{
					global.grid_terrains[i][j].type = "normal"
				}
			}
		}
	}
	with obj_card_parent{
		if plant_id == "wooden_plate"{
			instance_destroy()
		}
	}
}

if global.level_id == "cheese_castle" && obj_battle.current_wave == 5 && obj_battle.current_subwave == 9 && obj_battle.wave_timer == 1{
	for(var i = 0 ; i < 7 ; i ++){
		global.row_feature[i] = "land"
	}
}