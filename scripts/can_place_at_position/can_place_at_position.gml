/// @function can_plant_at_position(x, y, plant_type,feature_type,target_card)
/// @description 检查是否可以在指定位置种植植物
/// @param {real} x X坐标
/// @param {real} y Y坐标
/// @param {string} plant_type 植物类型
/// @param {string} feature_type 植物特性
/// @param {string} target_card 底座卡片
function can_place_at_position(x, y, plant_type,feature_type,target_card) {
    // 获取网格位置
    var grid_pos = get_grid_position_from_world(x, y);
    var col = grid_pos.col;
    var row = grid_pos.row;
    
    // 检查是否在网格范围内
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) {
        return false;
    }
	//调试相关
	if global.debug{
		return true
	}
	// 检查是否有障碍
	if global.grid_terrains[row][col].type == "obstacle" && plant_type != "coffee"{
		return false
	}
    
    // 获取该网格的植物列表
    var plant_list = ds_grid_get(global.grid_plants, col, row);
    
    // 根据植物类型检查是否可以种植
	if target_card != "none"{
		var same = false
		//检查是否有同类
		for (var i = 0; i < ds_list_size(plant_list); i++) {
		    var plant = ds_list_find_value(plant_list, i);
            if (!instance_exists(plant)) continue;
			if (plant.plant_type == plant_type && !global.replace_placement && feature_type != "upgrade") {
		        same = true
		    }
	                    
		}
		//检查是否有底座卡片
		for (var i = 0; i < ds_list_size(plant_list); i++) {
	        var plant = ds_list_find_value(plant_list, i);
                    if (!instance_exists(plant)) continue;
	        if (instance_exists(plant) && variable_instance_exists(plant, "plant_id") && plant.plant_id == target_card && !same) {
				
				return true;
				
	       }
	    }
		return false
	}
    switch (plant_type) {
        case "lilypad":
            // 莲叶花盆只能种在水上且该网格必须为空
			if global.grid_terrains[row][col].type == "water"{
	            if (ds_list_size(plant_list) == 0) {
	                // 空地上
	                //return (global.grid_terrain[# col, row] == "grass");
					return true
	            } else {
	                // 检查是否有同类
	                for (var i = 0; i < ds_list_size(plant_list); i++) {
	                    var plant = ds_list_find_value(plant_list, i);
                    	if (!instance_exists(plant)) continue;
	                    if ((plant.plant_type == "lilypad" && !global.replace_placement) || (plant.plant_type != "lilypad" && plant.feature_type == "water")) {
	                        return false;
	                    }
	                }
	                return true;
	            }
			}
			else{
				return false
			}
        case "coffee":
            if (ds_list_size(plant_list) == 0) {
                // 空地上
                //return (global.grid_terrain[# col, row] == "grass");
				return true
            } else {
                // 检查是否有同类
				if global.replace_placement{
						return true
					}
                for (var i = 0; i < ds_list_size(plant_list); i++) {
                    var plant = ds_list_find_value(plant_list, i);
                    if (!instance_exists(plant)) continue;
                    if (plant.plant_type == "coffee") {
                        //return false;
                    }
                }
                return true;
            }
            
        case "shield_outer":
            // 护罩植物只能种在普通植物或莲叶上
            if global.grid_terrains[row][col].type != "water"{
				if feature_type == "water"{
					return false
				}
	            if (ds_list_size(plant_list) == 0) {
	                // 空地上
	                //return (global.grid_terrain[# col, row] == "grass");
					return true
	            } else {
	                // 检查是否有同类
					if global.replace_placement{
						return true
					}
	                for (var i = 0; i < ds_list_size(plant_list); i++) {
	                    var plant = ds_list_find_value(plant_list, i);
                    	if (!instance_exists(plant)) continue;
	                    if (plant.plant_type == "shield_outer") {
	                        return false;
	                    }
	                }
	                return true;
	            }
			}
			else if global.grid_terrains[row][col].type == "water"{
				// 检查是否有同类
					var has_same = false
					if feature_type == "dwarf"{
						return false;
					}
					if feature_type == "water"{
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "shield_outer" && !global.replace_placement) {
		                        has_same = true
		                    }
	                    
		                }
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
		                    if (plant.plant_type == "lilypad" || has_same) {
		                        return false;
		                    }
						}
						return true
					}
					else if feature_type == "amphi"{
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "shield_outer" && !global.replace_placement) {
		                        return false
		                    }
	                    
		                }
						return true
					}
					else{
		                for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "shield_outer" && !global.replace_placement) {
		                        has_same = true
		                    }
	                    
		                }
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
		                    if (plant.plant_type == "lilypad" && !has_same) {
		                        return true;
		                    }
						}
						return false
                }
				
			}
            return false;
            
        case "normal":
			for (var i = 0; i < ds_list_size(plant_list); i++) {
	            var plant = ds_list_find_value(plant_list, i);
                    if (!instance_exists(plant)) continue;
	            if (instance_exists(plant) && variable_instance_exists(plant, "plant_id") && plant.plant_id == "player") {
	                return false;
	            }
	        }
            // 普通植物只能种在空地上或莲叶上
			if global.grid_terrains[row][col].type != "water"{
				if feature_type == "water"{
					return false
				}
	            if (ds_list_size(plant_list) == 0) {
	                // 空地上
	                //return (global.grid_terrain[# col, row] == "grass");
					return true
	            } else {
	                // 检查是否有同类
					if global.replace_placement{
						return true
					}
	                for (var i = 0; i < ds_list_size(plant_list); i++) {
	                    var plant = ds_list_find_value(plant_list, i);
                    	if (!instance_exists(plant)) continue;
	                    if (plant.plant_type == "normal") {
	                        return false;
	                    }
	                }
	                return true;
	            }
			}
			else if global.grid_terrains[row][col].type == "water"{
				// 检查是否有同类
					var has_same = false
					if feature_type == "dwarf"{
						return false;
					}
					if feature_type == "water"{
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "normal" && !global.replace_placement) {
		                        has_same = true
		                    }
	                    
		                }
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
		                    if (plant.plant_type == "lilypad" || has_same) {
		                        return false;
		                    }
						}
						return true
					}
					else if feature_type == "amphi"{
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "normal" && !global.replace_placement) {
		                        return false
		                    }
	                    
		                }
						return true
					}
					else{
		                for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
							if (plant.plant_type == "normal" && !global.replace_placement) {
		                        has_same = true
		                    }
	                    
		                }
						for (var i = 0; i < ds_list_size(plant_list); i++) {
		                    var plant = ds_list_find_value(plant_list, i);
                    		if (!instance_exists(plant)) continue;
		                    if (plant.plant_type == "lilypad" && !has_same) {
		                        return true;
		                    }
						}
						return false
                }
				
			}
            
        default:
            // 其他植物类型
            return ds_list_size(plant_list) == 0;
    }
}