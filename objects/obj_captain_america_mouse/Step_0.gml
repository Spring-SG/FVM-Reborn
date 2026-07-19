if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	skill_choose = irandom_range(0,0)
	skill_change_style = irandom_range(0,1)
	if skill_choose == 2{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 0{
		enemy_row = global.grid_rows-1
		enemy_pos = get_world_position_from_grid(9,enemy_row)  
	}
	else{
		enemy_row = 3
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 2000
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
		sprite_index = spr_captain_america_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 11
		}
		else{
			image_index = floor(timer/5) mod 11 + 11
		}
		if timer >= wait_time{
			timer = 0
			if skill_choose == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_choose == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_choose == 2{
				state = BOSS_STATE.SKILL3
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_captain_america_mouse_appear1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 11
		}
		else{
			image_index = floor(timer/5) mod 11 + 11
		}
		if timer == 11 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	
	case BOSS_STATE.SKILL1:
		if timer <= 28 * 5 - 1{
			sprite_index = spr_captain_america_mouse_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 28
			}
			else{
				image_index = floor(timer /5) mod 28 + 28
			}
		}
		else if timer <= 39* 5 - 1{
			sprite_index = spr_captain_america_mouse_disappear2
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-28*5) /5) mod 11
			}
			else{
				image_index = floor((timer-28*5) /5) mod 11 + 11
			}
		}
		else if timer <= 50 * 5 - 1{
			sprite_index = spr_captain_america_mouse_appear2
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-39*5) /5) mod 11
			}
			else{
				image_index = floor((timer-39*5) /5) mod 11 + 11
			}
		}
		else if timer <= 80 * 5 - 1{
			sprite_index = spr_captain_america_mouse_skill_1_idle
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-50*5) /5) mod 11
			}
			else{
				image_index = floor((timer-50*5) /5) mod 11 + 11
			}
		}
		else if timer <= 86 * 5 - 1{
			sprite_index = spr_captain_america_mouse_skill_1_return
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-80*5) /5) mod 6
			}
			else{
				image_index = floor((timer-80*5) /5) mod 6 + 6
			}
		}
		else{
			image_alpha = 0
		}
		
		if timer == 23*5+2{
			instance_create_depth(x-90,y-15,-800,obj_captain_shield)
		}
		if timer == 39 * 5 - 1{
			var enemy_pos = get_world_position_from_grid(9,0)
	
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
		}
		
		if timer >= 86 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_captain_america_mouse_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 54
		}
		else{
			image_index = floor(timer /5) mod 54 + 54
		}
		
		if timer >= 10 * 5 - 1 && jump_times < 5 && (timer-49) mod 45 == 1{
			var rainbow_pos = get_world_position_from_grid(6,5-jump_times)
			instance_create_depth(rainbow_pos.x,rainbow_pos.y,-800,obj_captain_rainbow)
			jump_times ++
		}
		if timer == 10 * 5 - 1{
			var mouse_pos = get_world_position_from_grid(9,1)
			instance_create_depth(mouse_pos.x,mouse_pos.y,-800,obj_aircraft_carrier)
			var mouse_pos1 = get_world_position_from_grid(9,global.grid_rows-2)
			instance_create_depth(mouse_pos1.x,mouse_pos1.y,-800,obj_aircraft_carrier)
		}
		
		
		if timer >= 54*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	case BOSS_STATE.SKILL3:
		
		skill_timer ++
		if skill_timer <= 11 * 5 - 1{
			sprite_index = spr_captain_america_mouse_disappear1
			if hp > maxhp * hurt_rate{
				image_index = floor(skill_timer /5) mod 21
			}
			else{
				image_index = floor(skill_timer /5) mod 21 + 21
			}
		}
		else if skill_timer <= 22 * 5 - 1{
			sprite_index = spr_captain_america_mouse_appear1
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-55) /5) mod 11
			}
			else{
				image_index = floor((skill_timer-55) /5) mod 11 + 11
			}
		}
		else if skill_timer <= 43* 5 - 1{
			sprite_index = spr_captain_america_mouse_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-110) /5) mod 21
			}
			else{
				image_index = floor((skill_timer-110) /5) mod 21 + 21
			}
		}
		else{
			sprite_index = spr_captain_america_mouse_idle
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-215) /5) mod 11
			}
			else{
				image_index = floor((skill_timer-215) /5) mod 11 + 11
			}
		}
		
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 3) {
			    // 生成随机坐标
			    var rand_x = irandom_range(2, 6);
			    var rand_y = irandom_range(0, global.grid_rows - 1);
			    var new_coord = [rand_x, rand_y];
    
			    // 检查是否已存在
			    var exists = false;
			    for (var i = 0; i < array_length(selected_coords); i++) {
			        if (selected_coords[i][0] == new_coord[0] && selected_coords[i][1] == new_coord[1]) {
			            exists = true;
			            break;
			        }
			    }
    
			    // 如果不存在则添加
			    if (!exists) {
			        array_push(selected_coords, new_coord);
			    }
			}
			target_coord = selected_coords
		}
		
		if timer mod 335 == 55{
			if jump_times < 3{
				var target_pos_array = target_coord[jump_times]
				var target_pos = get_world_position_from_grid(target_pos_array[0],target_pos_array[1])
				x = target_pos.x
				y = target_pos.y + 30
				jump_times ++
			}
		}
		if timer mod 335 == 0{
			skill_timer = 0
		}
		if timer mod 335 == 167{
			with obj_card_parent{
				if grid_col <= other.grid_col-1 && grid_col >= other.grid_col-2 && grid_row == other.grid_row &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
			var effect = instance_create_depth(x-140,y-180,-800,obj_coke_bomb_explode)
			effect.sprite_index = spr_captain_america_mouse_effect
		}
		
		if timer >= 3*335-1{
			jump_times = 0
			skill_timer = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_captain_america_mouse_disappear1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 11
		}
		else{
			image_index = floor(timer/5) mod 11 + 11
		}
		if timer == 11 * 5 - 1{
			image_alpha = 0
		}
		if timer == 180{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			skill_change_style = irandom_range(0,1)
			for(var i = 0 ; i < 100 ; i++){
				var current_choose = irandom_range(0,2)
				if current_choose != skill_choose{
					skill_choose = current_choose
					break
				}
			}
			if skill_choose == 2{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 0{
				enemy_row = global.grid_rows-1
				enemy_pos = get_world_position_from_grid(9,enemy_row) 
			}
			else{
				enemy_row = 3
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_captain_america_mouse_death
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

var base_depth = -10 - (zombie_grid.row * 45) - 45;
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

