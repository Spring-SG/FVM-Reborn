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

if global.level_id == "mustard_cottage_daytime" && obj_battle.current_wave >= global.level_file.elite_wave && obj_battle.level_stage != "boss"{
	if event_timer mod 1800 == 5{
		var b_col = irandom_range(0,8)
		var b_row = irandom_range(0,6)
		var target_pos = get_world_position_from_grid(b_col,b_row) 
		var inst = instance_create_depth(target_pos.x,target_pos.y+38,-500,obj_pink_paul_tentacle)
	}
}