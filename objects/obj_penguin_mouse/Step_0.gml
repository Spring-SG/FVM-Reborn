// Inherit the parent event

if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0 
	sprite_index = spr_penguin_mouse
}
event_inherited();

if global.is_paused or is_frozen{
	exit
}
throw_timer --
if (throw_timer <= 0 || state == ENEMY_STATE.ATTACK) && !throwed{
	throwed = true
	state = ENEMY_STATE.APPEAR
	timer = 0
}

if state == ENEMY_STATE.APPEAR{
	sprite_index = spr_penguin_mouse_throw	
	if hp > maxhp * hurt_rate{
		image_index = floor(timer/flash_speed) mod 9
	}
	else{
		image_index = floor(timer/flash_speed) mod 9 + 9
	}
	if timer >= flash_speed * 9 - 1 or hp <= 0{
		state = ENEMY_STATE.NORMAL
		sprite_index = spr_penguin_mouse
	}
	if timer == 6 * flash_speed - 1{
		for(var i = 0 ; i < grid_col;i++){
			target_col = -1
			var plant_list = ds_grid_get(global.grid_plants,i,grid_row)
			if ds_list_size(plant_list) > 0{
				for(var j = 0 ; j < ds_list_size(plant_list);j++){
					var plant_inst = plant_list[| j]
					if instance_exists(plant_inst){
						if(plant_inst.plant_type != "coffee" && plant_inst.feature_type != "dwarf"){
							target_col = i
							break
						}
					}
				}
			}
			if target_col != -1{
				break
			}
		}
		if target_col == -1{
			target_col = 0
		}
	
		var bullet = instance_create_depth(x-10,y-90,-800,obj_penguin_bullet)
		bullet.row = grid_row
		bullet.target_col = target_col
		bullet.damage = 10
			
		// 获取敌人当前位置和速度
		var bullet_pos = get_world_position_from_grid(target_col,grid_row)
		var enemy_x = bullet_pos.x
		var enemy_y = bullet_pos.y
    
		// 计算子弹飞行时间（基于水平距离和预设速度）
		var distance_x = enemy_x - bullet.x
		var flight_time = clamp(75 + (distance_x/1000) * 45, 75, 120)

		// 计算子弹所需的速度向量
		var total_distance_x = distance_x
		var total_distance_y = 600//enemy_y - inst.y
    
		// 抛物线运动参数计算:cite[6]
		bullet.move_speed = total_distance_x / flight_time
		bullet.cgravity = (2 * total_distance_y) / (flight_time * flight_time)
		bullet.cvspeed = (total_distance_y - 0.05 * bullet.cgravity * flight_time * flight_time) / flight_time
	}
	
}
