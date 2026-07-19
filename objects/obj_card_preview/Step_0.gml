// obj_plant_preview STEP 事件
var found_plat = noone;
platform_shift_x = 0;
platform_shift_y = 0;
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
        other.platform_shift_x = shift_x;
        other.platform_shift_y = shift_y;
        break;
    }
    
    var grid_pos_dir = get_grid_position_from_world(mouse_x, mouse_y);
    if (grid_pos_dir.col >= p_start_c && grid_pos_dir.col < p_start_c + width &&
        grid_pos_dir.row >= p_start_r && grid_pos_dir.row < p_start_r + length) {
        found_plat = id;
        logical_col = grid_pos_adj.col;
        logical_row = grid_pos_adj.row;
        other.platform_shift_x = shift_x;
        other.platform_shift_y = shift_y;
        break;
    }
}

if (found_plat == noone) {
    var grid_pos_direct = get_grid_position_from_world(mouse_x, mouse_y);
    logical_col = grid_pos_direct.col;
    logical_row = grid_pos_direct.row;
}

var logical_world = get_world_position_from_grid(logical_col, logical_row);

var card_shape = get_card_info_simple(card_id).shape
var card_data = deck_get_card_data(card_id,card_shape)
is_valid = (can_place_at_position(logical_world.x, logical_world.y, card_data[? "plant_type"],card_data[? "feature_type"],card_data[? "target_card"]));

// 跟随鼠标移动
x = mouse_x;
y = mouse_y;
logical_base_x = logical_world.x;
logical_base_y = logical_world.y;

// 如果父卡槽被取消，销毁自己
if (parent_slot == noone || !instance_exists(parent_slot) || !parent_slot.is_selected) {
    instance_destroy();
}