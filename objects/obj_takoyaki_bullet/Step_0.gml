if global.is_paused{
	exit
}
timer++;
// 子弹追踪逻辑
if (instance_exists(target_enemy) && target_enemy.hp > 0) {
    // 目标存在且存活，继续追踪
    var target_x = target_enemy.x;
    var target_y = target_enemy.y-75;
    
    // 计算朝向目标的方向
    var dir = point_direction(x, y, target_x, target_y);
    x += lengthdir_x(move_speed, dir);
    y += lengthdir_y(move_speed, dir);
	//show_debug_message(dir)
    
    // 检查是否需要重新选择目标（有更高优先级的目标出现）
    var new_target = noone;
    var closest_left_enemy = noone;
	var air_enemy = noone
    var min_x = room_width;
    var max_hp = 0;
    var right_range = 150;
    
    // 寻找更高优先级的目标
    with (obj_enemy_parent) {
        if (hp > 0 && can_hit(other.target_type,target_type) && y > 0) {
            // 检查是否在子弹右边一格内（更高优先级）
			if instance_exists(other.banding_card_obj){
	            if (x >= other.banding_card_obj.x && x <= other.banding_card_obj.x + right_range && grid_row == other.row) {
	                if (new_target == noone || hp > new_target.hp){
	                    new_target = id;
	                }
	            }
			}
            
			if target_type == "air"{
				if air_enemy != noone && instance_exists(air_enemy){
					if x < air_enemy.x{
						air_enemy = id
					}
				}
				else{
					air_enemy = id
				}
			}
			
            // 检查是否比当前目标更靠左
            if (x < other.target_enemy.x) {
                if (closest_left_enemy == noone || x < min_x || (x == min_x && hp > max_hp)){
                    min_x = x;
                    max_hp = hp;
                    closest_left_enemy = id;
                }
            }
        }
    }
    
    // 如果找到更高优先级的目标，切换目标
    if (new_target != noone) {
        target_enemy = new_target;
    } else if (air_enemy != noone) {
        target_enemy = air_enemy;
    } else if (closest_left_enemy != noone) {
        target_enemy = closest_left_enemy;
    }
    
} else {
    // 目标不存在或已死亡，寻找新目标
    var new_target = noone;
    var closest_left_enemy = noone;
	var air_enemy = noone
    var min_x = room_width;
    var max_hp = 0;
    var right_range = 80;
    
    with (obj_enemy_parent) {
        if (hp > 0 && can_hit(other.target_type,target_type)) {
            // 检查是否在子弹右边一格内
			if instance_exists(other.banding_card_obj){
	            if (x >= other.banding_card_obj.x && x <= other.banding_card_obj.x + right_range && grid_row == other.row) {
	                if (new_target == noone || hp > new_target.hp) {
	                    new_target = id;
	                }
	            }
			}
			if target_type == "air"{
				if air_enemy != noone && instance_exists(air_enemy){
					if x < air_enemy.x{
						air_enemy = id
					}
				}
				else{
					air_enemy = id
				}
			}
            
            // 寻找最左侧敌人
            if (x < min_x || (x == min_x && hp > max_hp)){
                min_x = x;
                max_hp = hp;
                closest_left_enemy = id;
            }
        }
    }
    
    // 优先选择右边一格内的敌人，如果没有则选择最左侧敌人
    if (new_target != noone) {
        target_enemy = new_target;
    } else if (air_enemy != noone) {
        target_enemy = air_enemy;
    }else if (closest_left_enemy != noone) {
        target_enemy = closest_left_enemy;
    } else {
        // 没有敌人，按原方向继续飞行
        var dir = point_direction(xstart, ystart, x, y);
        x += lengthdir_x(move_speed, dir);
        y += lengthdir_y(move_speed, dir);
    }
}

image_angle =- timer * 6
if x > 2200 or y > 1200 or x < -200 or y < -200{
	instance_destroy()
}