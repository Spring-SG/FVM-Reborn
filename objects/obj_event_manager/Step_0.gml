if global.is_paused{
	exit
}

event_timer ++
{//（旧代码）硬编码的事件和地图物件
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
		if event_timer mod 1800 == 1799{
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

	if (global.level_id == "mustard_cottage_daytime" || global.level_id == "tower_cake_7_1" || global.level_id == "tower_cake_7_2" || global.level_id == "tower_cake_8_1" || global.level_id == "tower_cake_8_2") && event_timer == 1{
		var obs_pos = get_world_position_from_grid(6,5)
		var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
		inst.row = 5
	}
	if global.level_id == "mustard_cottage_night" && event_timer == 1{
		var obs_pos = get_world_position_from_grid(6,1)
		var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
		inst.row = 1
	}
	if (global.level_id == "tower_cake_9_1" || global.level_id == "tower_cake_9_2") && event_timer == 1{
		var obs_pos = get_world_position_from_grid(6,2)
		var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
		inst.row = 2
	}
	if (global.level_id == "cheese_castle" || global.level_id == "tower_cake_10_1" || global.level_id == "tower_cake_10_2") && event_timer == 1{
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
	if global.level_id == "charcoal_jungle_daytime" && event_timer == 1{
		var obs_pos = get_world_position_from_grid(7,0)
		var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
		inst.row = 0
		var obs_pos2 = get_world_position_from_grid(3,1)
		var inst2 = instance_create_depth(obs_pos2.x,obs_pos2.y-35,-1200,obj_obstacle)
		inst2.row = 1
		var obs_pos3 = get_world_position_from_grid(5,5)
		var inst3 = instance_create_depth(obs_pos3.x,obs_pos3.y-35,-1200,obj_obstacle)
		inst3.row = 5
		var obs_pos4 = get_world_position_from_grid(6,6)
		var inst4 = instance_create_depth(obs_pos4.x,obs_pos4.y-35,-1200,obj_obstacle)
		inst4.row = 6
	}
	if global.level_id == "charcoal_jungle_night" && event_timer == 1{
		var obs_pos = get_world_position_from_grid(6,0)
		var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_obstacle)
		inst.row = 0
		var obs_pos2 = get_world_position_from_grid(6,1)
		var inst2 = instance_create_depth(obs_pos2.x,obs_pos2.y-35,-1200,obj_obstacle)
		inst2.row = 1
		var obs_pos3 = get_world_position_from_grid(4,4)
		var inst3 = instance_create_depth(obs_pos3.x,obs_pos3.y-35,-1200,obj_obstacle)
		inst3.row = 4
		var obs_pos4 = get_world_position_from_grid(4,5)
		var inst4 = instance_create_depth(obs_pos4.x,obs_pos4.y-35,-1200,obj_obstacle)
		inst4.row = 5
		var obs_pos5 = get_world_position_from_grid(1,6)
		var inst5 = instance_create_depth(obs_pos5.x,obs_pos5.y-35,-1200,obj_obstacle)
		inst5.row = 6
	}
	if (global.level_id == "macchiato_port" || global.level_id == "tower_cake_15_1" || global.level_id == "tower_cake_15_2") && event_timer == 1{
		var obs_pos = get_world_position_from_grid(8,1)
		var inst = instance_create_depth(obs_pos.x+5,obs_pos.y-35,-1200,obj_wind_tunnel)
		inst.row = 1
		var obs_pos2 = get_world_position_from_grid(8,3)
		var inst2 = instance_create_depth(obs_pos2.x+5,obs_pos2.y-35,-1200,obj_wind_tunnel)
		inst2.row = 3
		var obs_pos3 = get_world_position_from_grid(8,5)
		var inst3 = instance_create_depth(obs_pos3.x+5,obs_pos3.y-35,-1200,obj_wind_tunnel)
		inst3.row = 5
		var obs_pos4 = get_world_position_from_grid(6,2)
		var inst4 = instance_create_depth(obs_pos4.x+5,obs_pos4.y-35,-1200,obj_wind_tunnel)
		inst4.row = 2
		var obs_pos5 = get_world_position_from_grid(6,4)
		var inst5 = instance_create_depth(obs_pos5.x+5,obs_pos5.y-35,-1200,obj_wind_tunnel)
		inst5.row = 4
	}
	if (global.level_id == "jam_tribe_daytime" || global.level_id == "tower_cake_19_1" || global.level_id == "tower_cake_19_2") && event_timer == 1{
		var lava_pos_list = [
		[0,0,0,0,1,1,1,0,0],
		[0,0,0,0,1,0,1,0,0],
		[0,0,0,0,1,1,1,0,0],
		[0,0,0,1,1,1,0,0,0],
		[0,0,0,1,1,1,0,0,0],
		[0,0,0,1,0,1,0,0,0],
		[0,0,0,1,1,1,0,0,0]
		]
		for(var i = 0 ; i < array_length(lava_pos_list) ; i++){
			for(var j = 0 ; j < array_length(lava_pos_list[i]) ; j++){
			
				if lava_pos_list[i][j] == 1{ 
					var obs_pos = get_world_position_from_grid(j,i)
					var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_lava)
					inst.row = i
					inst.col = j
					inst.depth = calculate_plant_depth(j,i,"coffee")
				}
			}
		}
	}
	if (global.level_id == "jam_tribe_night" || global.level_id == "tower_cake_18_1" || global.level_id == "tower_cake_18_2") && event_timer == 1{
		var lava_pos_list = [
		[0,0,0,0,0,1,1,0,0],
		[0,0,0,0,0,0,1,0,0],
		[0,0,0,0,0,1,1,0,0],
		[0,0,0,0,1,1,0,0,0],
		[0,0,0,0,1,1,0,0,0],
		[0,0,0,0,0,1,0,0,0],
		[0,0,0,0,1,1,0,0,0]
		]
		for(var i = 0 ; i < array_length(lava_pos_list) ; i++){
			for(var j = 0 ; j < array_length(lava_pos_list[i]) ; j++){
			
				if lava_pos_list[i][j] == 1{ 
					var obs_pos = get_world_position_from_grid(j,i)
					var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_lava)
					inst.row = i
					inst.col = j
					inst.depth = calculate_plant_depth(j,i,"coffee")
				}
			}
		}
	}
	if (global.level_id == "snowcap_volcano" || global.level_id == "tower_cake_20_1" || global.level_id == "tower_cake_20_2") && event_timer == 1{
		var lava_pos_list = [
		[0,0,0,0,1,1,0,0,1],
		[0,0,0,0,0,0,0,0,1],
		[0,0,1,1,0,0,0,1,1],
		[0,0,0,0,0,0,0,0,0],
		[0,0,1,1,0,0,0,0,0],
		[0,0,0,1,0,1,0,0,1],
		[0,0,0,0,0,0,0,0,1]
		]
		for(var i = 0 ; i < array_length(lava_pos_list) ; i++){
			for(var j = 0 ; j < array_length(lava_pos_list[i]) ; j++){
			
				if lava_pos_list[i][j] == 1{ 
					var obs_pos = get_world_position_from_grid(j,i)
					var inst = instance_create_depth(obs_pos.x,obs_pos.y-35,-1200,obj_lava)
					inst.row = i
					inst.col = j
					inst.depth = calculate_plant_depth(j,i,"coffee")
				}
			}
		}
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

	if (global.level_id == "cheese_castle" && obj_battle.current_wave == 6 && obj_battle.current_subwave == 0)
	|| ((global.level_id == "tower_cake_10_1" || global.level_id == "tower_cake_10_2") && obj_battle.current_wave == 2 && obj_battle.current_subwave == 1){
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

	if (global.level_id == "cheese_castle" && obj_battle.current_wave == 5 && obj_battle.current_subwave == 9 && obj_battle.wave_timer == 1)
	||((global.level_id == "tower_cake_10_1" || global.level_id == "tower_cake_10_2") && obj_battle.current_wave == 2 && obj_battle.current_subwave == 0 && obj_battle.wave_timer == 1){
		for(var i = 0 ; i < 7 ; i ++){
			global.row_feature[i] = "land"
		}
	}

	if global.level_id == "cotton_candy_sky_daytime" || global.level_id == "tower_cake_16_1" || global.level_id == "tower_cake_16_2"{
		if event_timer mod 1800 == 1799{
			can_cloud_hole_summon = true
		}
		if event_timer == 1{
			for(var i = 2 ; i < global.grid_cols  ; i ++){
				for(var j = 0 ; j < global.grid_rows  ; j ++){
					var cloud_pos = get_world_position_from_grid(i,j)
					var cloud_inst = instance_create_depth(cloud_pos.x,cloud_pos.y-10,10,obj_cloud)
					cloud_inst.image_index = cloud_count mod 2
					cloud_inst.depth += cloud_count mod 2
					cloud_inst.image_alpha = 1
				}
				cloud_count ++
			}
		}
		if event_timer mod 480 == 1{
			var hole_row = -1
			if can_cloud_hole_summon{
				hole_row = irandom_range(0,global.grid_rows-1)
			}
			for(var i = 0 ; i < global.grid_rows  ; i ++){
				var cloud_pos = get_world_position_from_grid(9,i)
				var cloud_inst = instance_create_depth(cloud_pos.x,cloud_pos.y-10,10,obj_cloud)
				cloud_inst.image_index = cloud_count mod 2
				cloud_inst.depth += cloud_count mod 2
				if i == hole_row{
					cloud_inst.is_hole = true
				}
			}
			can_cloud_hole_summon = false
			cloud_count ++
		}
	}
	if global.level_id == "cotton_candy_sky_night" || global.level_id == "tower_cake_17_1" || global.level_id == "tower_cake_17_2"{
		if event_timer mod 1800 == 1799{
			can_cloud_hole_summon = true
		}
		if event_timer == 1{
			for(var i = 2 ; i < global.grid_cols  ; i ++){
				for(var j = 0 ; j < global.grid_rows  ; j ++){
					var cloud_pos = get_world_position_from_grid(i,j)
					var cloud_inst = instance_create_depth(cloud_pos.x,cloud_pos.y-10,10,obj_cloud)
					cloud_inst.image_index = cloud_count mod 2
					cloud_inst.depth += cloud_count mod 2
					cloud_inst.image_alpha = 1
					cloud_inst.sprite_index = spr_cloud_night
				}
				cloud_count ++
			}
		}
		if event_timer mod 480 == 1{
			var hole_row = -1
			if can_cloud_hole_summon{
				hole_row = irandom_range(0,global.grid_rows-1)
			}
			for(var i = 0 ; i < global.grid_rows  ; i ++){
				var cloud_pos = get_world_position_from_grid(9,i)
				var cloud_inst = instance_create_depth(cloud_pos.x,cloud_pos.y-10,10,obj_cloud)
				cloud_inst.image_index = cloud_count mod 2
				cloud_inst.depth += cloud_count mod 2
				cloud_inst.sprite_index = spr_cloud_night
				if i == hole_row{
					cloud_inst.is_hole = true
				}
			}
			can_cloud_hole_summon = false
			cloud_count ++
		}
	}
}

//为版本号大于1.5的关卡执行事件
if is_real(global.level_file.version){
	if global.level_file.version >= 1.5{
		var event_list = struct_get(global.level_file,"events")
		//遍历事件数组
		for(var i = 0 ; i < array_length(event_list) ; i++){
			//处理蝙蝠鼠生成事件
			if event_list[i].id == "bat_mouse_spawn"{
				if event_timer mod (event_list[i].interval*60) == (event_list[i].interval*60-1){
					for(var __count__ = 0 ; __count__ < event_list[i].mouse_amount ; __count__++){
						var b_col = irandom_range(0,global.grid_cols-1)
						var b_row = irandom_range(0,global.grid_rows-1)
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
			}
			//处理老鼠洞生成事件
			if event_list[i].id == "mouse_hole_spawn"{
				if event_timer mod (event_list[i].interval*60) == 5{
					for(var __count__ = 0 ; __count__ < event_list[i].hole_amount ; __count__++){
						var can_summon = true
						for(var hole_try_count = 0 ; hole_try_count < 100;hole_try_count++){
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
							if ds_list_size(plant_list)>0 or global.grid_terrains[cave_pos.row][cave_pos.col].type == "water"{
								can_summon = false
							}
							if can_summon{
								instance_create_depth(cave_pos.x,cave_pos.y,-5,obj_mouse_hole)
								break
							}
						}
					}
				}
			}
			//处理突袭鼠生成事件
			if event_list[i].id == "assault_mouse_spawn"{
				if event_timer mod (event_list[i].interval*60) == (event_list[i].interval*60-1){
					for(var __count__ = 0 ; __count__ < event_list[i].mouse_amount ; __count__++){
						for(var assault_try = 0 ; assault_try < 100 ; assault_try ++){
							var b_col = irandom_range(4,global.grid_cols-1)
							var b_row = irandom_range(0,global.grid_rows-1)
							var target_pos = get_world_position_from_grid(b_col,b_row)
							if global.grid_terrains[b_row][b_col].type == "water"{
								var inst = instance_create_depth(target_pos.x+10,target_pos.y+33,-500,obj_assault_mouse)
								inst.grid_col = b_col
								inst.grid_row = b_row
								break
							}
						}
					}
				}
			}
			//处理迷雾生成
			if event_list[i].id == "fog_spawn"{
				if event_timer == 1{
					for(var f_row = 0 ; f_row < global.grid_rows ; f_row++){
						for(var j = clamp(global.grid_cols-event_list[i].fog_cols,0,global.grid_cols-1) ; j < global.grid_cols+3;j++){
							if array_get_index(event_list[i].fog_rows,f_row+1) != -1{
								var pos = get_world_position_from_grid(j,f_row)
								var fog = instance_create_depth(pos.x+10,pos.y-50,-800,obj_fog)
								fog.col = j
								fog.row = f_row
							}
						}
					}
				}
			}
			//处理云和云洞生成
			if event_list[i].id == "cloud"{
				if event_timer mod (event_list[i].interval*60) == (event_list[i].interval*60 - 1){
					can_cloud_hole_summon = true
				}
				if event_timer == 1{
					for(var c_col = 2 ; c_col < global.grid_cols  ; c_col ++){
						for(var c_row = 0 ; c_row < global.grid_rows  ; c_row ++){
							if array_get_index(event_list[i].cloud_rows,c_row+1) != -1{
								var cloud_pos = get_world_position_from_grid(c_col,c_row)
								var cloud_inst = instance_create_depth(cloud_pos.x,cloud_pos.y-10,10,obj_cloud)
								cloud_inst.image_index = cloud_count mod 2
								cloud_inst.depth += cloud_count mod 2
								cloud_inst.image_alpha = 1
								if event_list[i].cloud_type == "night"{
									cloud_inst.sprite_index = spr_cloud_night
								}
							}
						}
						cloud_count ++
					}
				}
				if event_timer mod 480 == 1{
					var hole_row = -1
					if can_cloud_hole_summon{
						hole_row = irandom_range(0,array_length(event_list[i].cloud_rows)-1)
					}
					for(var c_row = 0 ; c_row < global.grid_rows  ; c_row ++){
						if array_get_index(event_list[i].cloud_rows,c_row+1) != -1{
							var cloud_pos = get_world_position_from_grid(9,c_row)
							var cloud_inst = instance_create_depth(cloud_pos.x,cloud_pos.y-10,10,obj_cloud)
							cloud_inst.image_index = cloud_count mod 2
							cloud_inst.depth += cloud_count mod 2
							if event_list[i].cloud_type == "night"{
								cloud_inst.sprite_index = spr_cloud_night
							}
							if can_cloud_hole_summon{
								if c_row+1 == event_list[i].cloud_rows[hole_row]{
									cloud_inst.is_hole = true
								}
							}
						}
					}
					can_cloud_hole_summon = false
					cloud_count ++
				}
			}
			//处理退潮事件
			if event_list[i].id == "tide_cheese_castle"{
				if obj_battle.current_wave == event_list[i].target_wave && obj_battle.current_subwave == 0 && obj_battle.wave_timer == 1{
					for(var c_row = 0 ; c_row < 7 ; c_row ++){
						global.row_feature[c_row] = "land"
					}
				}
				if obj_battle.current_wave == event_list[i].target_wave && obj_battle.current_subwave == 1{
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
		
						for(var c_row = 0 ; c_row < global.grid_rows ; c_row++){
							for(var j = 0 ; j < global.grid_cols ; j++){
								if global.grid_terrains[c_row][j].type == "water"{
									global.grid_terrains[c_row][j].type = "normal"
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
				
			}
		}
	}
}


//浮空岛移动板块事件
if global.level_id == "fennel_raft_daytime" && event_timer == 1{
	// 平台1：位于 1~4 列，0~4 行，初始向向下移动
	var pos1 = get_world_position_from_grid(1, 0)
	var plat1 = instance_create_depth(pos1.x - global.grid_cell_size_x/2, pos1.y - global.grid_cell_size_y/2 - 35, 800, obj_platform)
	plat1.sprite_index = spr_fennel_raft_platform_daytime
	plat1.start_col = 1
	plat1.start_row = 0
	plat1.width = 4
	plat1.length = 5
	plat1.move_distance = 2
	plat1.move_direction = 1

	// 平台2：位于 5~8 列，2~6 行，初始向上移动
	var pos2 = get_world_position_from_grid(5, 2)
	var plat2 = instance_create_depth(pos2.x - global.grid_cell_size_x/2, pos2.y - global.grid_cell_size_y/2 - 35, 800, obj_platform)
	plat2.sprite_index = spr_fennel_raft_platform_daytime
	plat2.start_col = 5
	plat2.start_row = 2
	plat2.width = 4
	plat2.length = 5
	plat2.move_distance = 2
	plat2.move_direction = -1
}