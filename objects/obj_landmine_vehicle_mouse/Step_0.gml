// Inherit the parent event

if global.is_paused{
	exit
}

event_inherited();

if is_frozen || is_stun{
	exit
}

if (hp <= 0) {
	sprite_index = spr_landmine_vehicle_mouse
	if state != ENEMY_STATE.DEAD{
	    timer = 0;
	    state = ENEMY_STATE.DEAD;
	}
    target_plant = noone;  // 清除攻击目标
}

if state != ENEMY_STATE.DEAD && state != ENEMY_STATE.ACTING && state != ENEMY_STATE.APPEAR{
	target_col = -1
	var target_range = clamp(grid_col,0,global.grid_cols - 1)
	for(var i = 0 ; i < target_range;i++){
		var plant_list = ds_grid_get(global.grid_plants,i,grid_row)
		if ds_list_size(plant_list) > 0{
			for(var j = 0 ; j < ds_list_size(plant_list);j++){
				var plant_inst = plant_list[| j]
				if instance_exists(plant_inst){
					if(plant_inst.plant_type != "coffee" && plant_inst.feature_type != "dwarf"){
						target_col = i
						attack_timer = 0
						state = ENEMY_STATE.ACTING
						break
					}
				}
			}
		}
	}
}

var current_cycle = 0
var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
	current_cycle = cycle*2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
	current_cycle = cycle
}

if state == ENEMY_STATE.APPEAR{
	if hp > 0{
		anim_timer++
		x -= current_move_speed
		image_index = floor(anim_timer/flash_speed) mod 6
		if x <= get_world_position_from_grid(9,grid_row).x{
			anim_timer = 0
			sprite_index = spr_landmine_vehicle_mouse
			state = ENEMY_STATE.NORMAL
		}
	}
}

if state == ENEMY_STATE.ACTING{
	for(var i = 0 ; i < grid_col;i++){
		target_col = -1
		state = ENEMY_STATE.NORMAL
		var plant_list = ds_grid_get(global.grid_plants,i,grid_row)
		if ds_list_size(plant_list) > 0{
			for(var j = 0 ; j < ds_list_size(plant_list);j++){
				var plant_inst = plant_list[| j]
				if instance_exists(plant_inst){
					if(plant_inst.plant_type != "coffee" && plant_inst.feature_type != "dwarf"){
						target_col = i
						state = ENEMY_STATE.ACTING
						break
					}
				}
			}
		}
		if target_col != -1{
			break
		}
	}
	attack_timer++
	if attack_timer < current_cycle - flash_speed * attack_anim{
		if (hp/maxhp > hurt_rate) {
			image_index = floor(timer / flash_speed) mod move_anim;
		} else {
			image_index = (floor(timer / flash_speed) mod move_anim) + move_anim;
		}
	}
	else if attack_timer < current_cycle{
		anim_timer++
		if (hp/maxhp > hurt_rate) {
			image_index = floor(anim_timer / flash_speed) mod attack_anim + move_anim * 2; 
		} else {
			image_index = (floor(anim_timer / flash_speed) mod attack_anim) + move_anim * 2 + attack_anim;
		}
		if attack_timer == current_cycle - flash_speed * 7{
			var bullet = instance_create_depth(x-10,y-220,-200,obj_engineer_bullet)
			bullet.row = grid_row
			bullet.target_col = target_col
			bullet.damage = 50
			bullet.sprite_index = spr_landmine_bullet
			
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
	else{
		attack_timer = 0
		anim_timer = 0
	}
}