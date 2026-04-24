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
    
    // 初始位移
    current_offset = initial_offset;
    
    // 调整平台初始视觉位置
    var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");
    var visual_offset_x = is_axis_x ? current_offset * global.grid_cell_size_x : 0;
    var visual_offset_y = (!is_axis_x) ? current_offset * global.grid_cell_size_y : 0;
    x += visual_offset_x;
    y += visual_offset_y;
    
    // 计算初始位置的行列
    var c_offset = is_axis_x ? current_offset : 0;
    var r_offset = (!is_axis_x) ? current_offset : 0;
    var cur_start_c = start_col + c_offset;
    var cur_start_r = start_row + r_offset;
    
    // 初始化初始位置的地形
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

// 计算动态起点的行列（兼容 x 与 y 轴偏移）
var c_offset = (variable_instance_exists(id, "move_axis") && move_axis == "x") ? current_offset : 0;
var r_offset = (!variable_instance_exists(id, "move_axis") || move_axis == "y") ? current_offset : 0;
var cur_start_c = start_col + c_offset;
var cur_start_r = start_row + r_offset;

if (state == "idle") {
    idle_timer++;
    var current_idle_duration = initial_idle_done ? boundary_idle_duration : initial_idle_duration;
    if (idle_timer >= current_idle_duration) {
        state = "moving";
        idle_timer = 0;
        initial_idle_done = true;
    }
} 
else if (state == "moving") {
    move_progress += move_speed;
    
    // 计算这一步的视觉位移 delta，并应用给植物
    var delta_progress = move_speed;
    var is_finish = false;
    
    if (move_progress >= 1.0) {
        delta_progress -= (move_progress - 1.0); // 截断超出的部分
        move_progress = 1.0;
        is_finish = true;
    }
    
    var is_axis_x = (variable_instance_exists(id, "move_axis") && move_axis == "x");
    var visual_delta_x = is_axis_x ? delta_progress * move_direction * global.grid_cell_size_x : 0;
    var visual_delta_y = !is_axis_x ? delta_progress * move_direction * global.grid_cell_size_y : 0;
    
    // 更新平台整体记录的总偏差（用于修正放置位置和预览）
    visual_x_shift = is_axis_x ? (move_progress * move_direction * global.grid_cell_size_x) : 0;
    visual_y_shift = (!is_axis_x) ? (move_progress * move_direction * global.grid_cell_size_y) : 0;
    
    // 平台本身的贴图位移
    x += visual_delta_x;
    y += visual_delta_y;
    
    // 带领当前区域内的植物同步位移
    for (var c = cur_start_c; c < cur_start_c + width; c++) {
        for (var r = cur_start_r; r < cur_start_r + length; r++) {
            if (r >= 0 && r < global.grid_rows && c >= 0 && c < global.grid_cols) {
                var plant_list = ds_grid_get(global.grid_plants, c, r);
                for (var i = 0; i < ds_list_size(plant_list); i++) {
                    var plant = ds_list_find_value(plant_list, i);
                    if (instance_exists(plant)) {
                        plant.x += visual_delta_x;
                        plant.y += visual_delta_y;
                        if (variable_instance_exists(plant, "target_x")) plant.target_x += visual_delta_x;
                        if (variable_instance_exists(plant, "target_y")) plant.target_y += visual_delta_y;
                        
                        // 星级同步移动
                        if (variable_instance_exists(plant, "banding_star_obj") && instance_exists(plant.banding_star_obj)) {
                            plant.banding_star_obj.x += visual_delta_x;
                            plant.banding_star_obj.y += visual_delta_y;
                        }
                        
                        
                        // 其他附属特效和武器（例如玩家的盾牌、武器、其他带有 parent_plant 或 parent_player 的特效）
                        with (all) {
                            if ((variable_instance_exists(id, "parent_plant") && parent_plant == plant) || 
                                (variable_instance_exists(id, "parent_player") && parent_player == plant)) {
                                if (id != plant) {
                                    x += visual_delta_x;
                                    y += visual_delta_y;
                                    if (variable_instance_exists(id, "target_x")) target_x += visual_delta_x;
                                    if (variable_instance_exists(id, "target_y")) target_y += visual_delta_y;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // 【逻辑同步】
    if (is_finish) {
        // 完成1格迁移前，先恢复旧区域边缘的地形为原本属性
        if (!is_axis_x) {
            // Y移动：如果是向下移动，离开的是顶部的 1 行；向上移动，离开的是底部的 1 行
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
            // X移动：如果是向右移动，离开的是左边的 1 列；向左移动，离开的是右边的 1 列
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
        
        // 完成1格迁移，数组搬家
        if (!is_axis_x) {
            // [Y轴移动搬家逻辑]
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
                            if (instance_exists(plant)) plant.row = target_r;
                        }
                        ds_list_clear(old_list);
                    }
                }
            }
        } 
        else {
            // [X轴移动搬家逻辑]
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
                            if (instance_exists(plant)) plant.col = target_c; 
                            // 注意：根据游戏引擎实际逻辑，有些系统只依赖row，但如果原逻辑拥有col，这里保证严谨设置
                        }
                        ds_list_clear(old_list);
                    }
                }
            }
        }
        
        current_offset += move_direction;
        move_progress = 0;
        visual_x_shift = 0;
        visual_y_shift = 0;
        
        // 重新计算占据后的区域并设置为 "normal" (无论是否是极限边缘)
        var new_c_offset = is_axis_x ? current_offset : 0;
        var new_r_offset = (!is_axis_x) ? current_offset : 0;
        var new_cur_start_c = start_col + new_c_offset;
        var new_cur_start_r = start_row + new_r_offset;
        
        // 将新的占用区域设为 "normal"
        for (var c = new_cur_start_c; c < new_cur_start_c + width; c++) {
            for (var r = new_cur_start_r; r < new_cur_start_r + length; r++) {
                if (r >= 0 && r < global.grid_rows && c >= 0 && c < global.grid_cols) {
                    global.grid_terrains[r][c].type = "normal";
                }
            }
        }
        
        // 检查是否到达极限边界
if (abs(current_offset) >= move_distance || current_offset == 0) {
    state = "idle";
    move_direction *= -1; // 反转方向
    initial_idle_done = true; // 确保后续使用边界停留时间
}
    }
}




