//step事件
if global.is_paused{
	exit
}
current_cost = cost
if ds_map_find_value(global.plus_card_map,card_id) != undefined{
	var plus_info = ds_map_find_value(global.plus_card_map,card_id)
	with plus_info[0]{
		if shape < plus_info[1]{
			other.current_cost += 50
		}
	}
}
if global.debug{
	cooldown_timer = cooldown
}
if cooldown_timer < cooldown{
	cooldown_timer ++


    // 冷却中状态
    is_ready = false;
    cooling_alpha = min(cooling_alpha + 0.05, 0.7); // 淡入冷却效果
} else {
    // 冷却完成状态
    cooling_alpha = max(cooling_alpha - 0.05, 0); // 淡出冷却效果
    
    // 检查阳光是否足够
    if (global.flame >= current_cost) {
        is_ready = true;
    } else {
        is_ready = false;
    }
}

// 检测鼠标悬停（用于显示提示）
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var is_hovered = point_in_rectangle(mx, my, x-42, y-55, x+42, y+50);

// 控制悬停提示透明度
if (is_hovered) {
    hover_alpha = min(hover_alpha + 0.1, 1);
} else {
    hover_alpha = 0
}

// 检测鼠标点击（选中卡槽）
if (is_ready && mouse_check_button_pressed(mb_left)) {
    mx = mouse_x;
    my = mouse_y;
    
    if (point_in_rectangle(mx, my, x-50, y-70, x+50, y+70)) {
		
        select_slot()
        
        // 创建放置预览对象
        if (selected_preview == noone) {
            selected_preview = instance_create_depth(mouse_x, mouse_y, depth-2, obj_card_preview);
            selected_preview.preview_sprite = card_spr; // 设置预览精灵
			if place_preview != undefined{
				selected_preview.preview_sprite = place_preview
			}
            selected_preview.parent_slot = id; // 设置父卡槽
			selected_preview.card_id = card_id
        }
    }
}

var slot_key = global.keybind_map[? "卡槽" + string(slot_index)];

if keyboard_check_pressed(slot_key) && is_ready{
        // 选中当前卡槽
		if !is_selected{
			select_slot()
        
			if global.quick_placement{
				try_place_once()
			}
			else{
	        // 创建放置预览对象
		        if (selected_preview == noone) {
		            selected_preview = instance_create_depth(mouse_x, mouse_y, depth-2, obj_card_preview);
		            selected_preview.preview_sprite = card_spr; // 设置预览精灵
					if place_preview != undefined{
						selected_preview.preview_sprite = place_preview
					}
		            selected_preview.parent_slot = id; // 设置父卡槽
					selected_preview.card_id = card_id
		        }
			}
		}
		else{
			is_selected = false;
	        if (selected_preview != noone && instance_exists(selected_preview)) {
	            instance_destroy(selected_preview);
	        }
	        selected_preview = noone;
	        global.selected_slot = noone;
		}
    }

// 如果当前卡槽被选中，处理放置逻辑
if (is_selected) {
    // 更新预览位置
    if (selected_preview != noone && instance_exists(selected_preview)) {
        selected_preview.x = mouse_x;
        selected_preview.y = mouse_y;
    }
    
    // 右键取消选择
    if (mouse_check_button_pressed(mb_right)) or (keyboard_check_pressed(vk_escape)) {
        is_selected = false;
        if (selected_preview != noone && instance_exists(selected_preview)) {
            instance_destroy(selected_preview);
        }
        selected_preview = noone;
        global.selected_slot = noone;
    }
    
    // 左键尝试放置植物
    if (mouse_check_button_pressed(mb_left)) {
        // 检查是否在可种植区域
		
        var card_shape = get_card_info_simple(card_id).shape
		var card_data = deck_get_card_data(card_id,card_shape)
		
		if card_id == "magic_chicken"{
			if global.prev_place_id != ""{
				card_shape = get_card_info_simple(global.prev_place_id).shape
				card_data = deck_get_card_data(global.prev_place_id,card_shape)
			}
		}
        
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

        var can_plant = (can_place_at_position(logical_world.x, logical_world.y, card_data[? "plant_type"],card_data[? "feature_type"],card_data[? "target_card"]));
        
        if (can_plant && global.flame >= current_cost) {
            // 创建植物实例
			var plant_list = ds_grid_get(global.grid_plants, logical_col, logical_row);
			var target_card_id = card_data[? "target_card"];
			
			// 如果有target_card，替换底座卡片
			if (target_card_id != undefined && target_card_id != "none") {
				// 销毁目标卡片
				for (var i = 0; i < ds_list_size(plant_list); i++) {
					var plant = ds_list_find_value(plant_list, i);
					if (instance_exists(plant) && variable_instance_exists(plant, "plant_id") && plant.plant_id == target_card_id) {
						card_destroyed(plant);
						instance_destroy(plant);
						break;
					}
				}
			}
			// 通用替换逻辑（替换同类植物或开启替换模式）
			else if global.replace_placement{
				for (var i = 0; i < ds_list_size(plant_list); i++) {
					var plant = ds_list_find_value(plant_list, i);
					if (plant.plant_type == card_data[? "plant_type"] && plant.plant_id != "player" && plant.plant_type != "coffee") {
						card_destroyed(plant);
						instance_destroy(plant);
					}
				}
			}
            var new_plant = instance_create_depth(logical_world.x + platform_shift_x, logical_world.y + platform_shift_y, 0,card_obj);
			// 计算深度值
			var depth_value = calculate_plant_depth(logical_col, logical_row, new_plant.plant_type);
			card_created(new_plant, logical_col, logical_row);
			new_plant.depth = depth_value
			if global.grid_terrains[logical_row][logical_col].type == "normal"{
				instance_create_depth(logical_world.x + platform_shift_x, logical_world.y + platform_shift_y,-2,obj_place_effect)
			}
			else if global.grid_terrains[logical_row][logical_col].type == "water"{
				var inst = instance_create_depth(logical_world.x + platform_shift_x, logical_world.y + platform_shift_y + 20,-2500,obj_place_effect)
				inst.sprite_index = spr_enter_water_effect
			}
            
            // 扣除阳光
            global.flame -= current_cost;
			
            
            // 重置冷却计时器
            cooldown_timer = 0;
            is_ready = false;
			if array_get_index(cooldown_ignore_list,card_id) == -1{
				global.prev_place_id = card_id
			}
            
			if global.grid_terrains[logical_row][logical_col].type == "normal"{
				audio_play_sound(snd_place1,0,0)
			}
			else if global.grid_terrains[logical_row][logical_col].type == "water"{
				audio_play_sound(snd_enter_water,0,0)
			}
            // 取消选择
            is_selected = false;
            if (selected_preview != noone && instance_exists(selected_preview)) {
                instance_destroy(selected_preview);
            }
            selected_preview = noone;
            global.selected_slot = noone;
        }
    }
}

depth = -1 * slot_index - 1000
if info_got == false{
	event_user(0)
}