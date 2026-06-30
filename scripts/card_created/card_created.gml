/// @function plant_created(plant_inst, col, row)
/// @description 当植物创建时调用，更新网格数据
/// @param {instance} plant_inst 植物实例
/// @param {real} col 网格列
/// @param {real} row 网格行
function card_created(plant_inst, col, row) {
	
	if(global.network.mode=="client"&&!global.network.plant_able){
		var level = variable_instance_get(plant_inst, "current_level") ?? 0;
		send_message(global.network.server_socket, MSG_UNIT_REQUEST,level,col,row,object_get_name(plant_inst.object_index));
		return;
	}
	
    // 获取该网格的植物列表
    var plant_list = ds_grid_get(global.grid_plants, col, row);
    
    // 添加新植物到列表
    ds_list_add(plant_list, plant_inst);
    
    // 设置植物的网格位置
    plant_inst.grid_col = col;
    plant_inst.grid_row = row;
    
    // 更新植物的深度偏移（根据层级）
    plant_inst.depth_offset = ds_list_size(plant_list) * 5;
    
    // 更新所有植物的深度偏移
	sort_plants_in_grid(col, row)
	
	if(global.network.mode=="server"){
		
		var level = variable_instance_get(plant_inst, "current_level") ?? 0;
		var object_name = object_get_name(plant_inst.object_index);
		
		var _list = global.network.connected_clients;
		var _size = array_length(_list);
		for (var i = 0; i < _size; i++) {
			var _socket = _list[i];
			send_message(_socket, MSG_SPAWN_UNIT,global.network.net_instance_count  ,level,col,row,object_name);
		}
		add_net_id(plant_inst.id);
	}
	
}  