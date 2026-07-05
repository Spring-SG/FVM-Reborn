// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0) {
	instance_destroy()
}
event_inherited();

var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
}

var target_y = get_world_position_from_grid(target_col,target_row).y - 30


if global.network.mode == "client" && instance_exists(banding_target_inst)=false{
	exit;
}


if hp > 0 && state != ENEMY_STATE.DEAD && banding_target_inst.state != "appear"{
	if state == ENEMY_STATE.APPEAR{
		anim_timer++
		//x -= current_move_speed
		if anim_timer >= 120{
			if y < target_y{
				y += 15
			}
			else{
				y = target_y
				target_type = "normal"
			}
		}
		image_index = floor(anim_timer/flash_speed) mod 8
		if anim_timer >= 500{
			target_type = "normal"
			state = ENEMY_STATE.ACTING
			move_speed = 0
			anim_timer = 0
		}
	}
	if state == ENEMY_STATE.ACTING{
		anim_timer++
		image_index = floor(anim_timer/flash_speed) mod 9 + 8
		if anim_timer >= flash_speed * 9{
			target_type = "air"
			image_index = 16
			y -= 15
			with banding_target_inst{
				y -= 15
			}
			if y <= -200{
				instance_destroy()
			}
		}
		var plant_order_list = [noone,noone,noone,noone,noone]
		var plant_in_range = noone
		if anim_timer == flash_speed * 9{
			with (obj_card_parent) {
				var is_in_front = (grid_col == other.target_col && grid_row == other.target_row)
				
	            // 检查是否在攻击范围内
	            if (is_in_front) {
	                // 按铲除顺序优先选择
	                for (var i = 0; i < ds_list_size(global.shovel_order); i++) {
	                    var tar_type = ds_list_find_value(global.shovel_order, i);
                    
	                    if (plant_type == tar_type) {
	                        plant_order_list[i] = id;
	                        break;
	                    }
	                }
				
                
	                if (plant_in_range != noone) break;
	            }
	        }
		
			for(var i = 0 ; i < 4 ; i++){
				if plant_order_list[i] != noone{
					plant_in_range = plant_order_list[i]
					break
				}
			}
			
			if global.network.mode == "client"{
				exit;
			}
	        // 如果找到目标植物，进入攻击状态
	        if (plant_in_range != noone) {
	            if instance_exists(plant_in_range){
					with plant_in_range{
						if plant_id != "player"{
							var inst = instance_create_depth(x,y,depth+1,obj_card_stolen)
							inst.sprite_index = sprite_index
							inst.image_index = image_index
							instance_destroy()
						}
					}
				}
	        }
			
			
		}
	}
}