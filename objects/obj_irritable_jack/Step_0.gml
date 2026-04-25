if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	if skill_count == 2{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_count == 0{
		enemy_pos = get_world_position_from_grid(10,enemy_row)
	}
	else{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	x = enemy_pos.x - 80
	y = enemy_pos.y + 30
	image_alpha = 0
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 3000
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
	image_alpha = 1
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		sprite_index = spr_irritable_jack_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			break
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_irritable_jack_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 11
		}
		else{
			image_index = floor(timer/5) mod 11 + 11
		}
		image_alpha = timer/50
		if timer == 11 * 5 - 1{
			image_alpha = 1
			timer = 0
			if skill_count == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL4
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 3{
				state = BOSS_STATE.SKILL2
			}
			skill_count ++
			if skill_count >= 4{
				skill_count = 0
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		if timer <= 16 * 5 - 1{
			sprite_index = spr_irritable_jack_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 16
			}
			else{
				image_index = floor(timer/5) mod 16 + 16
			}
		}
		else{
			sprite_index = spr_irritable_jack_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-80)/5) mod 19
			}
			else{
				image_index = floor((timer-80)/5) mod 19 + 19
			}
		}
		if timer == 1{
			var t_pos = get_world_position_from_grid(irandom_range(1,4),grid_row)
			y_move_speed = (t_pos.y+33-y)/60
			x_move = (t_pos.x-x)/60
		}
		if timer > 15 && timer <= 30{
			y -= 3
		}
		if timer > 65 && timer <= 80{
			y += 3
		}
		if timer >= 20 && timer <= 80{
			x += x_move
			y += y_move_speed
		}
		if timer == 26*5-1{
			with obj_card_parent{
				if grid_col >= other.grid_col - 2 && grid_col <= other.grid_col && grid_row == other.grid_row &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
		}
		
		
		if timer >= 35 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL4:
		
		if timer <= 17 * 5 - 1{
			sprite_index = spr_irritable_jack_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 17
			}
			else{
				image_index = floor(timer /5) mod 17 + 17
			}
			image_alpha = timer/20
			if timer <= 20{
				y += 15
			}
		}
		else{
			sprite_index = spr_irritable_jack_skill_4
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-85) /5) mod 10
			}
			else{
				image_index = floor((timer-85) /5) mod 10 + 10
			}
			if timer >= 700{
				image_alpha -= 0.05
			}
			else{
				image_alpha = 1
			}
			x -= 1
		}
		if timer == 1{
			var head_row = irandom_range(0,global.grid_rows-1)
			while head_row == t_row{
				head_row = irandom_range(0,global.grid_rows-1)
			}
			for(var i = 0; i < global.grid_rows ; i++){
				if i != t_row{
					var rock_pos = get_world_position_from_grid(10,i)
					var rock_inst = instance_create_depth(rock_pos.x-90,rock_pos.y+33-300,depth,obj_irritable_jack_rock_skill_4)
					if i == head_row{
						rock_inst.prev_spr = spr_irritable_jack_head_skill_3
						rock_inst.next_spr = spr_irritable_jack_head_skill_4
					}
					else{
						rock_inst.prev_spr = spr_irritable_jack_body_skill_3
						rock_inst.next_spr = spr_irritable_jack_body_skill_4
					}
					rock_inst.maxhp = rock_inst.maxhp + rock_inst.maxhp*((maxhp/30000)*0.5)
					rock_inst.hp = rock_inst.maxhp
				}
			}
		}
		with obj_card_parent{
			if grid_col == other.grid_col && grid_row == other.grid_row &&
			plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		if timer >= 720{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.SKILL3
			skill_count ++
			var enemy_pos = get_world_position_from_grid(irandom_range(1,9),irandom_range(0,global.grid_rows - 1))
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			image_alpha = 0
			y -= 300
		}
		break
		
	case BOSS_STATE.SKILL3:
		if skill_timer < 12 * 5 * 4{
			timer = 0
			skill_timer ++
			if skill_timer == 1{
				y -= 800
				// 创建已选坐标数组
				var selected_coords = [];

				// 循环直到选出4个不同的坐标
				while (array_length(selected_coords) < 4) {
				    // 生成随机坐标
				    var rand_x = irandom_range(0, 8);
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
			if skill_timer mod 60 == 5{
				var coord_choose = target_coord[rock_count]
				var rock_pos = get_world_position_from_grid(coord_choose[0],coord_choose[1])
				var rock_inst = instance_create_depth(rock_pos.x+10,rock_pos.y+33-300,-800,obj_irritable_jack_rock_skill_3)
				rock_inst.target_col = coord_choose[0]
				rock_inst.target_row = coord_choose[1]
				if rock_count == 0{
					rock_inst.sprite_index = spr_irritable_jack_head_skill_3
				}
				else{
					rock_inst.sprite_index = spr_irritable_jack_body_skill_3
				}
				
				rock_count ++
			}
			if skill_timer == 238{
				y += 800
			}
		}
		else{
			if timer <= 17 * 5 - 1{
				sprite_index = spr_irritable_jack_skill_3
				if hp > maxhp * hurt_rate{
					image_index = floor(timer /5) mod 17
				}
				else{
					image_index = floor(timer /5) mod 17 + 17
				}
				image_alpha = timer/20
				if timer <= 20{
					y += 15
				}
			}
			else{
				sprite_index = spr_irritable_jack_skill_4_return
				if hp > maxhp * hurt_rate{
					image_index = floor((timer-85) /5) mod 15
				}
				else{
					image_index = floor((timer-85) /5) mod 15 + 15
				}
			}
			if timer == 21{
				with obj_card_parent{
					if grid_col == other.grid_col && grid_row == other.grid_row &&
					plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
			}
		
			if timer >= 32*5-1{
				jump_times = 0
				timer = 0
				state = BOSS_STATE.IDLE
				skill_timer = 0
				rock_count = 0
			}
		}
		break
	case BOSS_STATE.SKILL2:
		
		if timer <= (6 * 5 - 1){
			sprite_index = spr_irritable_jack_skill_2_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 6
			}
			else{
				image_index = floor(timer /5) mod 6 + 6
			}
		}
		else if timer <= 6*5 + 7 * 5 * 6 - 1{
			sprite_index = spr_irritable_jack_skill_2
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-30) /5) mod 7
			}
			else{
				image_index = floor((timer-30) /5) mod 7 + 7
			}
		}
		else{
			sprite_index = spr_irritable_jack_skill_2_ready
			if hp > maxhp * hurt_rate{
				image_index = 6 - floor((timer-240) /5) mod 6
			}
			else{
				image_index = (6 - floor((timer-240) /5) mod 6) + 6
			}
		}
		if timer mod 70 == 15{
			var tg_row = irandom_range(0,global.grid_rows-1)
			var tg_y = get_world_position_from_grid(9,tg_row).y + 33
			var inst = instance_create_depth(x-80,y,-800,obj_irritable_jack_fire)
			inst.y_move = (tg_y-y)/120
		}
		
		if timer >= 240+6*5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_irritable_jack_appear
		image_alpha = clamp(1 - timer/50,0,1)
		if hp > maxhp * hurt_rate{
			image_index = 11 - floor(timer/5) mod 11
		}
		else{
			image_index = (11 - floor(timer/5) mod 11) + 11
		}
		if timer == 11 * 5 - 1{
			image_alpha = 0
		}
		if timer == 240{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 2{
				enemy_pos = get_world_position_from_grid(10,enemy_row)
			}
			else if skill_count == 0{
				enemy_pos = get_world_position_from_grid(10,enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(10,enemy_row)
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 33
			
			timer = 0
			if skill_count != 1{
				state = BOSS_STATE.APPEAR
				image_alpha = 1
			}
			else{
				state = BOSS_STATE.SKILL4
				image_alpha = 0
				y -= 300
				t_row = enemy_pos.row
				skill_count ++
			}
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_irritable_jack_death
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

