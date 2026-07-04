//恢复移动板块内地形

var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");

var new_c_offset = is_axis_x ? current_offset : 0;
var new_r_offset = (!is_axis_x) ? current_offset : 0;
var new_cur_start_c = start_col + new_c_offset;
var new_cur_start_r = start_row + new_r_offset;
        
for (var c = new_cur_start_c; c < new_cur_start_c + width; c++) {
    for (var r = new_cur_start_r; r < new_cur_start_r + length; r++) {
        if (r >= 0 && r < global.grid_rows && c >= 0 && c < global.grid_cols) {
            global.grid_terrains[r][c].type = "obstacle";
        }
    }
}