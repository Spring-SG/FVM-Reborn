if global.is_paused{
	exit
}

if shape == "ice"{
	spr_list = [spr_ice_residue_appear,spr_ice_residue_skill_1_ready,spr_ice_residue_skill_1,spr_ice_residue_skill_2,spr_ice_residue_disappear,spr_ice_residue_death]
}
else{
	spr_list = [spr_fire_residue_appear,spr_fire_residue_skill_1_ready,spr_fire_residue_skill_1,spr_fire_residue_skill_2,spr_fire_residue_disappear,spr_fire_residue_death]
}

if flash_value > 0 {
	flash_value -= 10
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 750
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		sprite_index = spr_list[1]
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12
		}
		if timer >= wait_time{
			timer = 0
			if skill_count == 0{
				state = BOSS_STATE.SKILL1
				skill_count++
			}
			else{
				state = BOSS_STATE.SKILL2
				skill_count = 0
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_list[0]
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 9
		}
		else{
			image_index = floor(timer/5) mod 9 + 9
		}
		if timer == 9 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL2:
		sprite_index = spr_list[3]
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 17
		}
		else{
			image_index = floor(timer/5) mod 17 + 17
		}
		
		var target_col = 0
		
		for(j = 0 ; j < global.grid_cols;j++){
			var plant_list = ds_grid_get(global.grid_plants, j, grid_row);
			if ds_list_size(plant_list) != 0{
				target_col = j
				break
			}
		}
		
		if (timer mod 85) == 45{
			var bullet = instance_create_depth(x-60,y-180,-200,obj_ice_residue_bullet)
			bullet.row = grid_row
			bullet.target_col = target_col
			bullet.damage = 2000
			bullet.sprite_index = spr_ice_residue_bullet
			
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
		if timer >= 17 * 5 * 5{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL1:
		if timer <= 8 * 10 * 3 - 1{
			sprite_index = spr_list[1]
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 8
			}
			else{
				image_index = floor(timer/5) mod 8 + 8
			}
		}
		else{
			sprite_index = spr_list[2]
			if hp > maxhp * hurt_rate{
				image_index = floor((timer - 8 * 5 * 3)/5) mod 16
			}
			else{
				image_index = floor((timer - 8 * 5 * 3)/5) mod 16 + 16
			}
		}
		
		if timer == 8 * 10 * 3 + 6 * 5{
			var inst = instance_create_depth(x-80,y-5,-500,obj_ice_residue_ball)
			if shape == "ice"{
				inst.shape = "ice"
				inst.sprite_index = spr_ice_residue_ball
			}
			else{
				inst.shape = "fire"
				inst.sprite_index = spr_fire_residue_ball
			}
		}
		if timer == 8 * 10 * 3 + 16 * 5 - 1{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_list[4]
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 9
		}
		else{
			image_index = floor(timer/5) mod 9 + 9
		}
		if timer == 9 * 5 - 1{
			image_alpha = 0
		}
		if timer == 210{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = get_world_position_from_grid(10,enemy_row)
			x = enemy_pos.x - 80
			y = enemy_pos.y + 30
			image_alpha = 1
			var shape_i = irandom_range(1,100)
			if shape_i <= 50{shape = "ice"}
			else{shape = "fire"}
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	case BOSS_STATE.STUN:
		
		if timer >= 300{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
	
		break
	
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_list[5]
		image_index = floor(timer/5) mod image_number
		if timer >= image_number * 5{
			image_alpha -= 0.1
			image_index = image_number - 1
		}
		break
}


timer ++


// 透明度处理
if (image_alpha <= 0 && state == BOSS_STATE.DEATH) {
    instance_destroy();
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

