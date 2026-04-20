if not is_placed{
	var logical_x = mouse_x;
	var logical_y = mouse_y;
	var platform_shift_x = 0;
	var platform_shift_y = 0;
	var plat = instance_position(mouse_x, mouse_y, obj_platform);
	if (plat != noone) {
		platform_shift_x = plat.visual_x_shift;
		platform_shift_y = plat.visual_y_shift;
		logical_x -= platform_shift_x;
		logical_y -= platform_shift_y;
	}

	var can_plant = (can_place_at_position(logical_x, logical_y, "normal","amphi","none"));
	if can_plant{
		is_placed = true
		global.is_paused = false
		var grid_pos = get_grid_position_from_world(logical_x, logical_y)
		x = grid_pos.x + platform_shift_x
		y = grid_pos.y+10 + platform_shift_y
		grid_row = grid_pos.row
		grid_col = grid_pos.col
		card_created(id,grid_col,grid_row)
		audio_play_sound(snd_place1,0,0)
		instance_create_depth(x,y,-2,obj_place_effect)
		var plany_list = ds_grid_get(global.grid_plants,grid_col,grid_row)
		if global.grid_terrains[grid_row][grid_col].type == "water"{
			var card = instance_create_depth(x,y-10,depth+1,obj_wooden_plate)
			card_created(card,grid_col,grid_row)
			
		}
		var gem_index = 0
		if global.save_data.equipped_items.main_weapon.id != ""{
			var main_info = get_weapon_info(global.save_data.equipped_items.main_weapon.id)
			var main_weapon_inst = instance_create_depth(x-10,y-100,depth-1,main_info.obj)
			main_weapon_inst.parent_player = id
			main_weapon_inst.grid_row = grid_row
			main_weapon_inst.grid_col = grid_col
			cycle = main_info.cycle
			var gem_list = global.save_data.equipped_items.main_weapon.gems
			for(var i = 0 ; i < array_length(gem_list);i++){
				var gem_id = gem_list[i]
				var gem_info = get_gem_info(gem_id)
				if gem_info.obj != noone{
					instance_create_depth(390,213+gem_index*80,-500,gem_info.obj)
					gem_index++
				}
			}
		}
		if global.save_data.equipped_items.secondary_weapon.id != ""{
			var s_inst = instance_create_depth(x,y,depth,obj_player_shield)
			s_inst.parent_player = id
			s_inst.grid_row = grid_row
			s_inst.grid_col = grid_col
			var main_info = get_weapon_info(global.save_data.equipped_items.secondary_weapon.id)
			hp += main_info.hp_increase
			max_hp += main_info.hp_increase
			if get_gem_index("health_gem") != -1{
				hp += get_gem_info("health_gem").hp_increase * (get_gem_level("health_gem")+1)
				max_hp += get_gem_info("health_gem").hp_increase * (get_gem_level("health_gem")+1)
			}
		}
		if global.save_data.equipped_items.super_weapon.id != ""{
			var main_info = get_weapon_info(global.save_data.equipped_items.super_weapon.id)
			var main_weapon_inst = instance_create_depth(x-10,y-100,depth-1,main_info.obj)
			main_weapon_inst.parent_player = id
			main_weapon_inst.grid_row = grid_row
			main_weapon_inst.grid_col = grid_col
		}
	}
	
}