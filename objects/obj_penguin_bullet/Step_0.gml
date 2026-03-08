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
        if(abs(grid_col-erase_col) <= 1 && abs(grid_row-erase_row) <= 1) {
            if !invincible{
				frozen_timer = 240
				ice_timer = 600
			}
        }
    }
	
	//var inst_y = get_world_position_from_grid(target_col,row).y
	var inst = instance_create_depth(x,y,-200,obj_coke_bomb_explode)
	inst.sprite_index = spr_ice_bucket_bomb_explode
	instance_destroy()
}