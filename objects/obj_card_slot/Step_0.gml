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

        var can_plant = (can_place_at_position(logical_x, logical_y, card_data[? "plant_type"],card_data[? "feature_type"],card_data[? "target_card"]));
        
        if (can_plant && global.flame >= current_cost) {
            // 创建植物实例
			var grid_pos = get_grid_position_from_world(logical_x, logical_y);
			var plant_list = ds_grid_get(global.grid_plants, grid_pos.col, grid_pos.row);
			if global.replace_placement{
			for (var i = 0; i < ds_list_size(plant_list); i++) {
	                    var plant = ds_list_find_value(plant_list, i);
	                    if (plant.plant_type == card_data[? "plant_type"] && plant.plant_id != "player" &&plant.plant_type != "coffee") {
	                        card_destroyed(plant)
							instance_destroy(plant)
	                    }
	                }
			}
            var new_plant = instance_create_depth(grid_pos.x + platform_shift_x, grid_pos.y + platform_shift_y, 0,card_obj);
			//new_plant.plant_type = plant_type;
			// 计算深度值
			var depth_value = calculate_plant_depth(grid_pos.col, grid_pos.row, new_plant.plant_type);
			card_created(new_plant, grid_pos.col, grid_pos.row);
			new_plant.depth = depth_value
			if global.grid_terrains[grid_pos.row][grid_pos.col].type == "normal"{
				instance_create_depth(grid_pos.x + platform_shift_x, grid_pos.y + platform_shift_y,-2,obj_place_effect)
			}
			else if global.grid_terrains[grid_pos.row][grid_pos.col].type == "water"{
				var inst = instance_create_depth(grid_pos.x + platform_shift_x, grid_pos.y + platform_shift_y + 20,-2500,obj_place_effect)
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
            
			if global.grid_terrains[grid_pos.row][grid_pos.col].type == "normal"{
				audio_play_sound(snd_place1,0,0)
			}
			else if global.grid_terrains[grid_pos.row][grid_pos.col].type == "water"{
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