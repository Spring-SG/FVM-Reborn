if is_selected{
    var found_plat = noone;
    var shovel_platform_shift_x = 0;
    var shovel_platform_shift_y = 0;
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
            shovel_platform_shift_x = shift_x;
            shovel_platform_shift_y = shift_y;
            break;
        }
        
        var grid_pos_dir = get_grid_position_from_world(mouse_x, mouse_y);
        if (grid_pos_dir.col >= p_start_c && grid_pos_dir.col < p_start_c + width &&
            grid_pos_dir.row >= p_start_r && grid_pos_dir.row < p_start_r + length) {
            found_plat = id;
            logical_col = grid_pos_adj.col;
            logical_row = grid_pos_adj.row;
            shovel_platform_shift_x = shift_x;
            shovel_platform_shift_y = shift_y;
            break;
        }
    }

    if (found_plat == noone) {
        var grid_pos_direct = get_grid_position_from_world(mouse_x, mouse_y);
        logical_col = grid_pos_direct.col;
        logical_row = grid_pos_direct.row;
    }

    var logical_world = get_world_position_from_grid(logical_col, logical_row);

    var draw_pos_x = logical_world.x + shovel_platform_shift_x;
    var draw_pos_y = logical_world.y + shovel_platform_shift_y;
    var is_valid = can_place_at_position(logical_world.x, logical_world.y, "coffee","normal","none");
    if (is_valid) {
        draw_sprite_ext(shovel_spr, 0, draw_pos_x+10, draw_pos_y-55, 1.8, 1.8, 0, c_white, 0.5);
    }
    draw_sprite_ext(shovel_spr,0,mouse_x+50,mouse_y-50,1.8,1.8,0,c_white,1)
}