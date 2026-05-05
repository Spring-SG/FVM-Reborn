if global.is_paused{
	exit
}

event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

attack_timer++

if attack_timer == 15 * current_flash_speed - 1{
	var card_save_data = get_card_info_simple(target_card)
	if card_save_data != false{
		var prev_card_info = get_plant_data_with_skill(target_card,card_save_data.shape,card_save_data.level,card_save_data.skill)
		var card_slot_data = deck_get_card_data(target_card,card_save_data.shape)
		
		var found_plat = noone;
		var platform_shift_x = 0;
		var platform_shift_y = 0;
		var logical_col = -1;
		var logical_row = -1;
		
		with (obj_platform) {
		    var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");
		    var shift_x = is_axis_x ? visual_x_shift : 0;
		    var shift_y = (!is_axis_x) ? visual_y_shift : 0;
		    var adj_x = other.x - shift_x;
		    var adj_y = other.y - shift_y;
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
		    
		    var grid_pos_dir = get_grid_position_from_world(other.x, other.y);
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
		    var grid_pos_direct = get_grid_position_from_world(x, y);
		    logical_col = grid_pos_direct.col;
		    logical_row = grid_pos_direct.row;
		}
		
		var logical_world = get_world_position_from_grid(logical_col, logical_row);
		var new_card = instance_create_depth(logical_world.x + platform_shift_x, logical_world.y + platform_shift_y, 0, card_slot_data[? "obj"])	
		card_created(new_card, logical_col, logical_row)
	}
}

if attack_timer > current_flash_speed * 29 - 1{
	instance_destroy()
}