//create事件
cooldown = 7 * 60
card_obj = obj_small_fire
card_spr = spr_small_fire
place_preview = spr_small_fire
card_id = ""
cost = 50
current_cost = 0
night = false
cooldown_timer = 30000
description = "小火炉:生产火苗"
slot_index = 0
clevel = 0
cshape = 0
cskill = 0
info_got = false

is_ready = true           // 卡槽是否可用
is_selected = false       // 卡槽是否被选中
hover_alpha = 0           // 悬停提示透明度
cooling_alpha = 0         // 冷却覆盖层透明度

selected_preview = noone;  // 当前选中的预览对象
preview_alpha = 0.5;      // 放置预览的透明度

image_xscale = 0.33
image_yscale = 0.33
image_speed = 0

cooldown_ignore_list = ["ice_cream","magic_chicken"]

//选择卡槽逻辑
function select_slot(){
	// 选中当前卡槽
        is_selected = true;
        
        // 如果有全局选中卡槽，取消其选中状态
		var shovel_slot = instance_find(obj_shovel_slot, 0);
        if (instance_exists(shovel_slot) && shovel_slot.is_selected) {
            deselect_shovel();
        }
        if (global.selected_slot != noone && global.selected_slot != id) {
            global.selected_slot.is_selected = false;
            instance_destroy(global.selected_slot.selected_preview);
            global.selected_slot.selected_preview = noone;
        }
        audio_play_sound(snd_card_lift,0,0)
        // 设置全局选中卡槽为当前卡槽
        global.selected_slot = id;
}

//尝试放置逻辑
function try_place_once(){
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
		else if global.quick_placement{
			// 取消选择
            is_selected = false;
            if (selected_preview != noone && instance_exists(selected_preview)) {
                instance_destroy(selected_preview);
            }
            selected_preview = noone;
            global.selected_slot = noone;
		}
}