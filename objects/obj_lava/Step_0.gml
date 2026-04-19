if global.is_paused{
	exit
}
if global.debug{
	image_alpha = 0.5
}
var grid_pos = get_world_position_from_grid(col,row)
timer++

with obj_card_parent{
	if plant_id == "cotton_candy" && grid_row == other.row && grid_col == other.col{
		on_lava = true
	}
}

if timer mod 60 == 0{
	var plant_in_range = noone;
        
	var plant_order_list = [noone,noone,noone,noone,noone]
		
    // 使用碰撞检测查找攻击范围内的植物
    with (obj_card_parent) {
		var dx = x - other.x;
		var dy = y - other.y;
		var is_in_front = false
		is_in_front = grid_row == other.row && grid_col == other.col
				
        // 检查是否在攻击范围内
        if (is_in_front) {
            // 按铲除顺序优先选择
            for (var i = 0; i < array_length(other.damage_order); i++) {
                var tar_type = other.damage_order[i]
                    
                if (plant_type == tar_type) {
                    plant_order_list[i] = id;
                    break;
                }
            }
                
        }
    }
	for(var i = 0 ; i < 5 ; i++){
		if plant_order_list[i] != noone{
			with plant_order_list[i]{
				if (plant_type != "coffee" && !invincible && plant_id != "cotton_candy") || (plant_id == "player" && hp > 10){
					hp -= 10
					event_user(2)
				}
			}
			break
		}
	}
	with obj_enemy_parent{
		if grid_row == other.row && grid_col == other.col &&
		(target_type == "normal" || target_type == "dance" || target_type == "obstacle"){
			hp -= 10
			event_user(0)

		}
		
	}
}
has_mouse = false
with obj_enemy_parent{
	if grid_row == other.row && grid_col == other.col &&
	(target_type == "normal" || target_type == "dance" || target_type == "obstacle"){
		other.has_mouse = true
		ice_timer = 0
		frozen_timer = 0
	}
}
