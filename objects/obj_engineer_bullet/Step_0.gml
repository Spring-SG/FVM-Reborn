if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}

var target_x = get_world_position_from_grid(target_col,row).x

if x > 2200 or y > 1200 or x < -200 or y < -200{
	instance_destroy()
}

x += move_speed
image_angle += 5
y -= cvspeed
cvspeed -= cgravity

if x >= target_x - 10 && x <= target_x + 10{
	var erase_col = target_col
	var erase_row = row
	// 检测前方植物
    var plant_in_range = noone;
        
	var plant_order_list = [noone,noone,noone,noone]
		
    // 使用碰撞检测查找攻击范围内的植物
    with (obj_card_parent) {
				
        // 检查是否在攻击范围内
        if(grid_col == erase_col && grid_row == erase_row) {
            // 按铲除顺序优先选择
            for (var i = 0; i < ds_list_size(global.shovel_order); i++) {
                var target_type = ds_list_find_value(global.shovel_order, i);
                    
                if (plant_type == target_type) {
                    plant_order_list[i] = id;
                    break;
                }
            }
                
            if (plant_in_range != noone) break;
        }
    }
	
	for(var i = 0 ; i < array_length(plant_order_list) ; i++){
		if plant_order_list[i] != noone && instance_exists(plant_order_list[i]){
			with plant_order_list[i]{
				hp -= other.damage
				event_user(2)
			}
			break
		}
	}
	
	//var inst_y = get_world_position_from_grid(target_col,row).y
	var inst = instance_create_depth(x,y,-200,obj_engineer_bullet_effect)
	if sprite_index == spr_ice_residue_bullet{
		inst.sprite_index = spr_ice_residue_bullet_effect
	}
	else if sprite_index == spr_landmine_bullet{
		inst.sprite_index = spr_landmine_bullet_effect
	}
	
	instance_destroy()
}