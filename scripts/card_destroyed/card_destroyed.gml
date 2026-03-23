/// @function plant_destroyed(plant_inst)
/// @description 当植物销毁时调用，更新网格数据
/// @param {instance} plant_inst 植物实例
function card_destroyed(plant_inst) {
    var col = plant_inst.grid_col;
    var row = plant_inst.grid_row;
    
    // 检查位置是否有效
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) {
        return;
    }
    
    // 获取该网格的植物列表
    var plant_list = ds_grid_get(global.grid_plants, col, row);
    
    // 从列表中移除植物
    var index = ds_list_find_index(plant_list, plant_inst);
    if (index != -1) {
        ds_list_delete(plant_list, index);
    }
    
    // 更新剩余植物的深度偏移
    //update_card_depths(col, row);
}