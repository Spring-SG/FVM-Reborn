// ========== 用户事件0 - 初始化 ==========
// (由父对象自动调用)
// 使用注册数据初始化属性
// 使用注册数据初始化属性
var plant_data = get_plant_data(plant_id);
current_level = 0
if (plant_data != undefined) {
    name = plant_data[? "name"];
    description = plant_data[? "description"];
	
	var card_save_data = get_card_info(plant_id)
	if card_save_data != false{
		current_level = card_save_data.level
		skill = card_save_data.skill
		shape = card_save_data.shape
	}
    
    // 应用基础属性
    var upgrade_data = get_plant_data_with_skill(plant_id, shape,current_level,skill);
    if (upgrade_data != undefined) {
        hp = upgrade_data[? "hp"];
		max_hp = hp
        cost = upgrade_data[? "cost"];
        atk = upgrade_data[? "atk"];
        range = upgrade_data[? "range"];
        cooldown = upgrade_data[? "cooldown"];
        cycle = upgrade_data[? "cycle"];
        
        // 获取自定义属性（如果存在）
        if (ds_map_exists(upgrade_data, "flame_produce")) {
            flame_produce = upgrade_data[? "flame_produce"];
        }
    }
	
}

if current_level >= 4{ //绑定星级贴图
	var inst = instance_create_depth(x,y-5,depth-1,obj_stars)
	var star_spr = -1
	switch current_level{
		case 4:star_spr = spr_star_4;break;
		case 5:star_spr = spr_star_5;break;
		case 6:star_spr = spr_star_6;break;
		case 7:star_spr = spr_star_7;break;
		case 8:star_spr = spr_star_8;break;
		case 9:star_spr = spr_star_9;break;
		case 10:star_spr = spr_star_10;break;
		case 11:star_spr = spr_star_11;break;
		case 12:star_spr = spr_star_12;break;
		case 13:star_spr = spr_star_13;break;
		case 14:star_spr = spr_star_14;break;
		case 15:star_spr = spr_star_15;break;
		case 16:star_spr = spr_star_16;break;
	}
	inst.sprite_index = star_spr
	inst.parent_card = id
	banding_star_obj = inst.id
}

var card_shape_data = get_card_info_simple(plant_id)
var card_shape = 0
if card_shape_data != false{
	card_shape = card_shape_data.shape
}
var card_data = deck_get_card_data(plant_id,card_shape)
plant_type = card_data[? "plant_type"]
feature_type = card_data[? "feature_type"]
target_card = card_data[? "target_card"]

var grid_pos = get_grid_position_from_world(x, y);
    var col = grid_pos.col;
    var row = grid_pos.row;


if global.network.mode=="client"{
	exit;
}
	
    // 检查是否在网格范围内
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) {
        exit
    }
    
    // 获取该网格的植物列表
    var plant_list = ds_grid_get(global.grid_plants, col, row);
    
    // 根据植物类型检查是否可以种植
	if target_card != "none"{
		for (var i = 0; i < ds_list_size(plant_list); i++) {
	        var plant = ds_list_find_value(plant_list, i);
			
			if instance_exists(plant)&&(plant.plant_id == target_card) {
				
				if feature_type == "upgrade"{
					instance_destroy(plant)
					break
				}
				
	       }
	    }
	}