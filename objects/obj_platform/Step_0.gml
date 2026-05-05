if (first_frame) {
    first_frame = false;
    
    if (!variable_instance_exists(id, "old_terrains")) {
        old_terrains = ds_grid_create(global.grid_cols, global.grid_rows);
        for (var c = 0; c < global.grid_cols; c++) {
            for (var r = 0; r < global.grid_rows; r++) {
                ds_grid_set(old_terrains, c, r, global.grid_terrains[r][c].type);
            }
        }
    }
    
    current_offset = initial_offset;
    
    // 预检初始方向，防止在边界处继续向外侧移动而突破限制
    // 同时如果处于该极端情况，视作已抵达边界，直接进入边界停留倒计时
    if (current_offset >= move_distance && move_direction > 0) {
        move_direction = -1;
        state = "idle";
        idle_timer = 0;
        initial_idle_done = true;
    } else if (current_offset <= -move_distance && move_direction < 0) {
        move_direction = 1;
        state = "idle";
        idle_timer = 0;
        initial_idle_done = true;
    }
    
    var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");
    var visual_offset_x = is_axis_x ? current_offset * global.grid_cell_size_x : 0;
    var visual_offset_y = (!is_axis_x) ? current_offset * global.grid_cell_size_y : 0;
    x += visual_offset_x;
    y += visual_offset_y;
    
    var c_offset = is_axis_x ? current_offset : 0;
    var r_offset = (!is_axis_x) ? current_offset : 0;
    var cur_start_c = start_col + c_offset;
    var cur_start_r = start_row + r_offset;
    
    for (var c = cur_start_c; c < cur_start_c + width; c++) {
        for (var r = cur_start_r; r < cur_start_r + length; r++) {
            if (r < global.grid_rows && c < global.grid_cols) {
                global.grid_terrains[r][c].type = "normal";
            }
        }
    }
}

if (global.is_paused) { 
    exit; 
}

var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");

if (state == "idle") {
    idle_timer++;
    var current_idle_duration = initial_idle_done ? boundary_idle_duration : initial_idle_duration;
    if (idle_timer >= current_idle_duration) {
        state = "moving";
        idle_timer = 0;
        initial_idle_done = true;
        move_progress = 0;
        step_migrated = false;
    }
} 
else if (state == "moving") {
    // 每步移动开始时迁移grid_plants
    if (!step_migrated) {
        step_migrated = true;
        
        var c_offset = is_axis_x ? current_offset : 0;
        var r_offset = (!is_axis_x) ? current_offset : 0;
        var cur_start_c = start_col + c_offset;
        var cur_start_r = start_row + r_offset;
        
        // 1. 恢复离开边缘的地形
        if (!is_axis_x) {
            var leave_r = (move_direction > 0) ? cur_start_r : (cur_start_r + length - 1);
            for (var c = cur_start_c; c < cur_start_c + width; c++) {
                if (leave_r >= 0 && leave_r < global.grid_rows && c >= 0 && c < global.grid_cols) {
                    if (variable_instance_exists(id, "old_terrains")) {
                        global.grid_terrains[leave_r][c].type = ds_grid_get(old_terrains, c, leave_r);
                    } else {
                        global.grid_terrains[leave_r][c].type = global.row_feature[leave_r];
                    }
                }
            }
        } else {
            var leave_c = (move_direction > 0) ? cur_start_c : (cur_start_c + width - 1);
            for (var r = cur_start_r; r < cur_start_r + length; r++) {
                if (r >= 0 && r < global.grid_rows && leave_c >= 0 && leave_c < global.grid_cols) {
                    if (variable_instance_exists(id, "old_terrains")) {
                        global.grid_terrains[r][leave_c].type = ds_grid_get(old_terrains, leave_c, r);
                    } else {
                        global.grid_terrains[r][leave_c].type = global.row_feature[r];
                    }
                }
            }
        }
        
        // 2. 迁移grid_plants
        if (!is_axis_x) {
            var r_start = (move_direction > 0) ? (cur_start_r + length - 1) : cur_start_r;
            var r_end   = (move_direction > 0) ? (cur_start_r - 1) : (cur_start_r + length);
            var r_step  = -move_direction;
            
            for (var c = cur_start_c; c < cur_start_c + width; c++) {
                if (c >= global.grid_cols || c < 0) continue;
                for (var r = r_start; r != r_end; r += r_step) {
                    var target_r = r + move_direction;
                    if ((r >= 0 && r < global.grid_rows) && (target_r >= 0 && target_r < global.grid_rows)) {
                        var old_list = ds_grid_get(global.grid_plants, c, r);
                        var new_list = ds_grid_get(global.grid_plants, c, target_r);
                        for (var i = 0; i < ds_list_size(old_list); i++) {
                            var plant = ds_list_find_value(old_list, i);
                            ds_list_add(new_list, plant);
                            if (instance_exists(plant)) {
                                plant.grid_row = target_r;
                            }
                        }
                        ds_list_clear(old_list);
                        ds_grid_set(global.grid_plants, c, target_r, new_list);
                        ds_grid_set(global.grid_plants, c, r, old_list);
                    }
                }
            }
        } 
        else {
            var c_start = (move_direction > 0) ? (cur_start_c + width - 1) : cur_start_c;
            var c_end   = (move_direction > 0) ? (cur_start_c - 1) : (cur_start_c + width);
            var c_step  = -move_direction;
            
            for (var r = cur_start_r; r < cur_start_r + length; r++) {
                if (r >= global.grid_rows || r < 0) continue;
                for (var c = c_start; c != c_end; c += c_step) {
                    var target_c = c + move_direction;
                    if ((c >= 0 && c < global.grid_cols) && (target_c >= 0 && target_c < global.grid_cols)) {
                        var old_list = ds_grid_get(global.grid_plants, c, r);
                        var new_list = ds_grid_get(global.grid_plants, target_c, r);
                        for (var i = 0; i < ds_list_size(old_list); i++) {
                            var plant = ds_list_find_value(old_list, i);
                            ds_list_add(new_list, plant);
                            if (instance_exists(plant)) {
                                plant.grid_col = target_c;
                            }
                        }
                        ds_list_clear(old_list);
                        ds_grid_set(global.grid_plants, target_c, r, new_list);
                        ds_grid_set(global.grid_plants, c, r, old_list);
                    }
                }
            }
        }
        
        // 3. 更新current_offset
        current_offset += move_direction;
        
        // 4. 设置新进入边缘的地形
        var new_c_offset = is_axis_x ? current_offset : 0;
        var new_r_offset = (!is_axis_x) ? current_offset : 0;
        var new_cur_start_c = start_col + new_c_offset;
        var new_cur_start_r = start_row + new_r_offset;
        
        for (var c = new_cur_start_c; c < new_cur_start_c + width; c++) {
            for (var r = new_cur_start_r; r < new_cur_start_r + length; r++) {
                if (r >= 0 && r < global.grid_rows && c >= 0 && c < global.grid_cols) {
                    global.grid_terrains[r][c].type = "normal";
                }
            }
        }
        
        // 5. 设置初始visual_shift
        visual_x_shift = is_axis_x ? (-move_direction * global.grid_cell_size_x) : 0;
        visual_y_shift = (!is_axis_x) ? (-move_direction * global.grid_cell_size_y) : 0;
    }
    
    // 移动动画
    move_progress += move_speed;
    
    var delta_progress = move_speed;
    var is_finish = false;
    
    if (move_progress >= 1.0) {
        delta_progress -= (move_progress - 1.0);
        move_progress = 1.0;
        is_finish = true;
    }
    
    var visual_delta_x = is_axis_x ? delta_progress * move_direction * global.grid_cell_size_x : 0;
    var visual_delta_y = !is_axis_x ? delta_progress * move_direction * global.grid_cell_size_y : 0;
    
    visual_x_shift = is_axis_x ? ((move_progress - 1) * move_direction * global.grid_cell_size_x) : 0;
    visual_y_shift = (!is_axis_x) ? ((move_progress - 1) * move_direction * global.grid_cell_size_y) : 0;
    
    x += visual_delta_x;
    y += visual_delta_y;
    
    // 带领植物同步位移
    var move_c_offset = is_axis_x ? current_offset : 0;
    var move_r_offset = (!is_axis_x) ? current_offset : 0;
    var move_cur_start_c = start_col + move_c_offset;
    var move_cur_start_r = start_row + move_r_offset;
    
    for (var c = move_cur_start_c; c < move_cur_start_c + width; c++) {
        for (var r = move_cur_start_r; r < move_cur_start_r + length; r++) {
            if (r >= 0 && r < global.grid_rows && c >= 0 && c < global.grid_cols) {
                var plant_list = ds_grid_get(global.grid_plants, c, r);
                for (var i = 0; i < ds_list_size(plant_list); i++) {
                    var plant = ds_list_find_value(plant_list, i);
                    if (instance_exists(plant)) {
                        plant.x += visual_delta_x;
                        plant.y += visual_delta_y;
                        if (variable_instance_exists(plant, "target_x")) plant.target_x += visual_delta_x;
                        if (variable_instance_exists(plant, "target_y")) plant.target_y += visual_delta_y;
                        
                        var grid_pos = get_grid_position_from_world(plant.x, plant.y);
                        plant.grid_col = grid_pos.col;
                        plant.grid_row = grid_pos.row;
                        if (variable_instance_exists(plant, "plant_type")) {
                            plant.depth = calculate_plant_depth(plant.grid_col, plant.grid_row, plant.plant_type);
                        }
                        
                        if (variable_instance_exists(plant, "banding_star_obj") && instance_exists(plant.banding_star_obj)) {
                            plant.banding_star_obj.x += visual_delta_x;
                            plant.banding_star_obj.y += visual_delta_y;
                        }
                        
                        with (all) {
                            if ((variable_instance_exists(id, "parent_plant") && parent_plant == plant) || 
                                (variable_instance_exists(id, "parent_player") && parent_player == plant)) {
                                if (id != plant) {
                                    x += visual_delta_x;
                                    y += visual_delta_y;
                                    if (variable_instance_exists(id, "target_x")) target_x += visual_delta_x;
                                    if (variable_instance_exists(id, "target_y")) target_y += visual_delta_y;
                                    
                                    if (object_index == obj_melon_shield_inner && instance_exists(parent_plant)) {
                                        depth = calculate_plant_depth(parent_plant.grid_col, parent_plant.grid_row, "shield_inner");
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    if (is_finish) {
        move_progress = 0;
        visual_x_shift = 0;
        visual_y_shift = 0;
        
        if (abs(current_offset) >= move_distance || current_offset == 0) {
            state = "idle";
            move_direction *= -1;
            initial_idle_done = true;
        } else {
            step_migrated = false;
        }
    }
}