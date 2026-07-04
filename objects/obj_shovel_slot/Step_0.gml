// 控制悬停提示透明度
if global.is_paused{
	exit
}
var slot_key = global.keybind_map[? "铲子"];
// 检测鼠标点击
if (mouse_check_button_pressed(mb_left)) {
    mx = mouse_x;
    my = mouse_y;
    
    if (point_in_rectangle(mx, my, x, y, x+150, y+150)) {
        select_shovel();
		audio_play_sound(snd_shovel,0,0)
    }
}
if keyboard_check_pressed(slot_key){
	if !is_selected{
		select_shovel();
		hotkey_pressed = true
		audio_play_sound(snd_shovel,0,0)
	}
	else{
		deselect_shovel();
	}
}
if ((mouse_check_button_pressed(mb_right) or keyboard_check_pressed(vk_escape)) && is_selected) {
    deselect_shovel();
}
// 在铲子槽对象 (obj_shovel_slot) 的鼠标点击处理中添加:
if ((is_selected && mouse_check_button_pressed(mb_left)) or (is_selected && global.quick_placement && hotkey_pressed)) {
    var found_plat = noone;
    var platform_shift_x = 0;
    var platform_shift_y = 0;
    var logical_col = -1;
    var logical_row = -1;
    
    with (obj_platform) {
        var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");
        var shift_x = is_axis_x ? visual_x_shift : 0;
        var shift_y = (!is_axis_x) ? visual_y_shift : 0;
        var adj_x = mouse_x - shift_x;
        var adj_y = mouse_y - shift_y;
        var grid_pos_adj = get_grid_position_from_world(adj_x, adj_y);
        
        var c_off = is_axis_x ? current_offset : 0;
        var r_off = (!is_axis_x) ? current_offset : 0;
        var p_start_c = start_col + c_off;
        var p_start_r = start_row + r_off;
        
        if (grid_pos_adj.col >= p_start_c && grid_pos_adj.col < p_start_c + width &&
            grid_pos_adj.row >= p_start_r && grid_pos_adj.row < p_start_r + length) {
            found_plat = id;
            logical_col = grid_pos_adj.col;
            logical_row = grid_pos_adj.row;
            platform_shift_x = shift_x;
            platform_shift_y = shift_y;
            break;
        }
        
        var grid_pos_dir = get_grid_position_from_world(mouse_x, mouse_y);
        if (grid_pos_dir.col >= p_start_c && grid_pos_dir.col < p_start_c + width &&
            grid_pos_dir.row >= p_start_r && grid_pos_dir.row < p_start_r + length) {
            found_plat = id;
            logical_col = grid_pos_dir.col;
            logical_row = grid_pos_dir.row;
            platform_shift_x = shift_x;
            platform_shift_y = shift_y;
            break;
        }
    }
    
    if (found_plat == noone) {
        var grid_pos_direct = get_grid_position_from_world(mouse_x, mouse_y);
        logical_col = grid_pos_direct.col;
        logical_row = grid_pos_direct.row;
    }
    
    var logical_world = get_world_position_from_grid(logical_col, logical_row);
    
    if (logical_col < 0 || logical_col >= global.grid_cols || logical_row < 0 || logical_row >= global.grid_rows) {
        return;
    }
    
    var plant_list = ds_grid_get(global.grid_plants, logical_col, logical_row);
    
    var plant_to_remove = noone;
    
    // 按照铲除顺序查找最上层的可移除植物
    for (var i = 0; i < ds_list_size(global.shovel_order); i++) {
        var target_type = ds_list_find_value(global.shovel_order, i);
        
        // 从上层开始查找（列表最后）
        for (var j = ds_list_size(plant_list) - 1; j >= 0; j--) {
            var plant = ds_list_find_value(plant_list, j);
			if instance_exists(plant){
	            if (plant.plant_type == target_type and plant.can_shovel_remove) {
	                plant_to_remove = plant;
	                break;
	            }
			}
        }
        
        if (plant_to_remove != noone) break;
    }
    
    // 移除找到的植物
    if (plant_to_remove != noone) {
        // 播放移除效果
        with (plant_to_remove) {
            // 播放移除动画
            var shovel_effect = instance_create_depth(x+10, y-55, depth, obj_shovel);
			shovel_effect.sprite_index = other.shovel_spr
			if other.flame_rate > 0{
				var flame_cost = get_plant_data_with_skill(plant_id,shape,current_level,skill)[? "cost"]
				var flame_inst = instance_create_depth(x,y-30,-2000,obj_flame)
				flame_inst.value = round(flame_cost * other.flame_rate)
			}
			if global.grid_terrains[logical_row][logical_col].type == "normal"{
				instance_create_depth(logical_world.x + platform_shift_x,logical_world.y + platform_shift_y,-2,obj_place_effect)
				audio_play_sound(snd_place2, 1, false);
			}
			else if global.grid_terrains[logical_row][logical_col].type == "water"{
				var inst = instance_create_depth(logical_world.x + platform_shift_x,logical_world.y + platform_shift_y + 20,-2500,obj_place_effect)
				inst.sprite_index = spr_enter_water_effect
				audio_play_sound(snd_enter_water,0,0)
			}
            instance_destroy();
        }
		
		deselect_shovel()
		
        sort_plants_in_grid(logical_col, logical_row);
        
    } else {
		// 没有找到可移除的植物
		
		var shovel_effect = instance_create_depth(logical_world.x + platform_shift_x, logical_world.y + platform_shift_y -55, depth, obj_shovel);
		shovel_effect.sprite_index = shovel_spr
		if global.grid_terrains[logical_row][logical_col].type == "normal"{
				instance_create_depth(logical_world.x + platform_shift_x,logical_world.y + platform_shift_y,-2,obj_place_effect)
				audio_play_sound(snd_place2, 1, false);
			}
			else if global.grid_terrains[logical_row][logical_col].type == "water"{
				var inst = instance_create_depth(logical_world.x + platform_shift_x,logical_world.y + platform_shift_y + 20,-2500,obj_place_effect)
				inst.sprite_index = spr_enter_water_effect
				audio_play_sound(snd_enter_water,0,0)
			}
		deselect_shovel()
        
    }
	hotkey_pressed = false
}