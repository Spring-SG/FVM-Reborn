if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
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
		target_type = "normal"
		sprite_index = spr_iron_man_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 16
		}
		else{
			image_index = floor(timer/5) mod 16 + 16
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.LAUNCH
			wait_time = 120
		}
		break
		
	case BOSS_STATE.APPEAR:
		target_type = "normal"
		sprite_index = spr_iron_man_mouse_drop
		
		image_index = floor(timer/5) mod 15
		
		if timer == 15 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		target_type = "air"
		if timer <= 20 * 5 - 1{
			sprite_index = spr_iron_man_mouse_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 20
			}
			else{
				image_index = floor(timer/5) mod 20 + 20
			}
		}
		else if timer <= 280{
			y -= 6
			sprite_index = spr_iron_man_mouse_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-100)/5) mod 6
			}
			else{
				image_index = floor((timer-100)/5) mod 6 + 6
			}
		}
		else if timer <= 460{
			y += 6
			sprite_index = spr_iron_man_mouse_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-100)/5) mod 6
			}
			else{
				image_index = floor((timer-100)/5) mod 6 + 6
			}
		}
		else{
			sprite_index = spr_iron_man_mouse_drop
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-460)/5) mod 15
			}
			else{
				image_index = floor((timer-460)/5) mod 15 + 15
			}
		}
		
		if timer >= 100 && timer <= 280 && jump_times < 7{
			if (timer-100) mod 20 == 1{
				with obj_card_parent{
					if grid_col == 6 && grid_row == (6 - other.jump_times) &&
					plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
				var effect_pos = get_world_position_from_grid(6,6-jump_times)
				var effect_inst = instance_create_depth(effect_pos.x,effect_pos.y-30,-800,obj_coke_bomb_explode)
				effect_inst.sprite_index = spr_iron_man_mouse_effect
				jump_times ++
			}
			
		}
		if timer >= 315 && timer <= 460 && jump_times < 7{
			if (timer-315) mod 20 == 1{
				with obj_card_parent{
					if grid_col == 3 && grid_row == (other.jump_times) &&
					plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
				var effect_pos = get_world_position_from_grid(3,jump_times)
				var effect_inst = instance_create_depth(effect_pos.x,effect_pos.y-30,-800,obj_coke_bomb_explode)
				effect_inst.sprite_index = spr_iron_man_mouse_effect
				jump_times ++
			}
			
		}
		
		if timer == 280{
			x = get_world_position_from_grid(4,0).x
			jump_times = 0
		}
		
		if timer >= 460 + 15 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		target_type = "normal"
		if timer <= 47 * 5 - 1{
			sprite_index = spr_iron_man_mouse_skill_2_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 47
			}
			else{
				image_index = floor(timer/5) mod 47 + 47
			}
		}
		else if timer <= 231 * 5 - 1{
			death_spr = spr_iron_man_mouse_death2
			sprite_index = spr_iron_man_mouse_skill_2_human
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-235)/5) mod 10
			}
			else{
				image_index = floor((timer-235)/5) mod 10 + 10
			}
		}
		else{
			death_spr = spr_iron_man_mouse_death
			sprite_index = spr_iron_man_mouse_skill_2_return
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-1155)/5) mod 30
			}
			else{
				image_index = floor((timer-1155)/5) mod 30 + 30
			}
		}
		if timer == 47 * 5{
			var iron_man_pos = get_world_position_from_grid(4,grid_row)
			var iron_man_inst = instance_create_depth(iron_man_pos.x,iron_man_pos.y+30,-800,obj_iron_man)
			iron_man_inst.train_head = id
			iron_man_inst.maxhp = maxhp
			iron_man_inst.hp = maxhp
			iron_man_inst.hp_modified = true
		}
		if timer == 261 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times = 0
		}
		break
		
	case BOSS_STATE.SKILL3:
		target_type = "normal"
		if timer <= 23 * 5 - 1{
			sprite_index = spr_iron_man_mouse_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 23
			}
			else{
				image_index = floor(timer/5) mod 23 + 23
			}
		}
		else if timer <= 38 * 5 - 1{
			sprite_index = spr_iron_man_mouse_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-115)/5) mod 5
			}
			else{
				image_index = floor((timer-115)/5) mod 5 + 5
			}
		}
		else{
			sprite_index = spr_iron_man_mouse_skill_3_return
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-190)/5) mod 9
			}
			else{
				image_index = floor((timer-190)/5) mod 9 + 9
			}
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 3) {
			    // 生成随机坐标
			    var rand_x = irandom_range(1, 7);
			    var rand_y = irandom_range(1, global.grid_rows - 2);
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
		
		if timer == 85{
			for(var i = 0 ; i < 3 ; i++){
				var target_inst_pos = target_coord[i]
				var inst_pos = get_world_position_from_grid(target_inst_pos[0],target_inst_pos[1])
				var iron_target_inst = instance_create_depth(inst_pos.x,inst_pos.y+15,-800,obj_coke_bomb_explode)
				iron_target_inst.sprite_index = spr_angelababy_target
			}
		}
		
		if timer >= 23*5 && timer <= 38 * 5 && jump_times < 3{
			if (timer-115) mod 25 == 21{
				var missile = instance_create_depth(x+35,y-420,-800,obj_iron_man_bullet)
				missile.target_col = target_coord[jump_times][0]
				missile.target_row = target_coord[jump_times][1]
				jump_times++
			}
		}
		
		if timer >= 47*5-1{
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times = 0
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_iron_man_mouse_launch
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer == 10 * 5 - 1{
			image_alpha = 0
		}
		if timer == 180{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = get_world_position_from_grid(10,enemy_row)
			x = enemy_pos.x - 50
			y = enemy_pos.y + 30
			image_alpha = 1
			var shape_i = irandom_range(1,100)
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	case BOSS_STATE.DROP:
		target_type = "air"
		sprite_index = spr_iron_man_mouse_drop
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 15
		}
		else{
			image_index = floor(timer/5) mod 15 + 15
		}
		if timer == 15 * 5 - 1{
			timer = 0
			if skill_choose == 0{
				state = BOSS_STATE.SKILL1
			}
			else if skill_choose == 1{
				state = BOSS_STATE.SKILL2
			}
			else{
				state = BOSS_STATE.SKILL3
			}
		}
		break
	case BOSS_STATE.LAUNCH:
		target_type = "air"
		sprite_index = spr_iron_man_mouse_launch
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer == 10 * 5 - 1{
			if !appear{
				skill_choose = irandom_range(0,1)
				appear = true
			}
			else{
				for(var i = 0 ; i < 100 ; i++){
					var current_choose = irandom_range(0,1)
					if hp <= maxhp * hurt_rate{
						current_choose = irandom_range(0,2)
					}
					if current_choose != skill_choose{
						skill_choose = current_choose
						break
					}
				}
			}
			if skill_choose == 0{
				target_pos.row = global.grid_rows-1
				target_pos.col = 7
				var land_pos = get_world_position_from_grid(target_pos.col,target_pos.row)
				x_move_speed = (land_pos.x - x)/180
				y_move_speed = (land_pos.y+30 - y)/180
				timer = 0
				state = BOSS_STATE.MOVE
			}
			else if skill_choose == 2{
				target_pos.row = irandom_range(1,global.grid_rows-1)
				target_pos.col = 9
				var land_pos = get_world_position_from_grid(target_pos.col,target_pos.row)
				x_move_speed = (land_pos.x-90 - x)/180
				y_move_speed = (land_pos.y+30 - y)/180
				timer = 0
				state = BOSS_STATE.MOVE
			}
			else{
				target_pos.row = 3
				target_pos.col = 9
				var land_pos = get_world_position_from_grid(target_pos.col,target_pos.row)
				x_move_speed = (land_pos.x-90 - x)/180
				y_move_speed = (land_pos.y+30 - y)/180
				timer = 0
				state = BOSS_STATE.MOVE
			}
		}
		break
	case BOSS_STATE.MOVE:
		target_type = "air"
		sprite_index = spr_iron_man_mouse_move
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		x += x_move_speed
		y += y_move_speed
		if timer >= 180{
			timer = 0
			state = BOSS_STATE.DROP
		}
		
		break
	
	
	case BOSS_STATE.DEATH:
		sprite_index = death_spr
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

var base_depth = -10 - (zombie_grid.row * 45) - 45
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

