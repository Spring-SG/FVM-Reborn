if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	skill_choose = irandom_range(0,2)
	skill_change_style = irandom_range(0,1)
	if skill_choose == 2{
		if skill_change_style == 0{
			enemy_row = 5
		}
		else{
			enemy_row = 1
		}
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 0{
		if skill_change_style == 0{
			enemy_row = 0
		}
		else{
			enemy_row = 1
		}
		enemy_pos = get_world_position_from_grid(10,enemy_row)
	}
	else{
		if skill_change_style == 0{
			enemy_pos = get_world_position_from_grid(8,5)
		}
		else{
			enemy_pos = get_world_position_from_grid(8,1)
		}
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
		sprite_index = spr_huang_xiaoming_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/6) mod 9
		}
		else{
			image_index = floor(timer/6) mod 9 + 9
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
		sprite_index = spr_huang_xiaoming_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/6) mod 4
		}
		else{
			image_index = floor(timer/6) mod 4
		}
		if timer == 4 * 6 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_huang_xiaoming_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 23
		}
		else{
			image_index = floor(timer/5) mod 23 + 23
		}
		
		if timer mod (23 * 5) == 14 * 5 - 2{
			var inst = instance_create_depth(x-45,y-30,depth,obj_xiaoming_text)
			if jump_times == 1{
				inst.sprite_index = spr_xiaoming_text_2
			}
			if jump_times == 2{
				inst.sprite_index = spr_xiaoming_text_3
			}
		}
		if timer mod (23 * 5) == 23 * 5 - 1 && jump_times < 2{
			y += global.grid_cell_size_y * 2
			jump_times ++
		}
		
		if timer >= 3 * 23*5 -1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		skill_timer++
		if jump_times == 0{
			if skill_timer <= 28 * 5 - 1{
				sprite_index = spr_huang_xiaoming_skill_2_ready
				if hp > maxhp * hurt_rate{
					image_index = floor(skill_timer /5) mod 28
				}
				else{
					image_index = floor(skill_timer /5) mod 28 + 28
				}
			}
			else if skill_timer <= 49* 5 - 1{
				sprite_index = spr_huang_xiaoming_skill_2
				if hp > maxhp * hurt_rate{
					image_index = floor((skill_timer-28*5) /5) mod 21
				}
				else{
					image_index = floor((skill_timer-28*5) /5) mod 21 + 21
				}
			}
			else if skill_timer <= 49*5 + 2 * 6 - 1{
				sprite_index = spr_huang_xiaoming_disappear
				image_index = floor((skill_timer-49*5) /6) mod 2
			}
			else{
				image_alpha = 0
			}
		}
		else if jump_times == 1{
			if skill_timer <= 4 * 6 - 1{
				image_alpha = 1
				sprite_index = spr_huang_xiaoming_appear
				image_index = floor(skill_timer /6) mod 4
			}
			else if skill_timer <= 4 * 6 + 28 * 5 - 1{
				sprite_index = spr_huang_xiaoming_skill_2_ready
				if hp > maxhp * hurt_rate{
					image_index = floor((skill_timer-24) /5) mod 28
				}
				else{
					image_index = floor((skill_timer-24) /5) mod 28 + 28
				}
			}
			else if skill_timer <= 4 * 6 + 49* 5 - 1{
				sprite_index = spr_huang_xiaoming_skill_2
				if hp > maxhp * hurt_rate{
					image_index = floor((skill_timer-28*5-24) /5) mod 21
				}
				else{
					image_index = floor((skill_timer-28*5-24) /5) mod 21 + 21
				}
			}
		}
		
		if jump_times == 0{
			if skill_timer == 37 * 5 - 1{
				var inst = instance_create_depth(x-120,y-30,-10,obj_coke_bomb_explode)
				inst.sprite_index = spr_xiaoming_ice
				var erase_col = grid_col - 1
				var erase_row = grid_row
		
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
			}
			if skill_timer == 49*5+2*6 +120{
				skill_timer = 0
				jump_times++
				var enemy_pos = {}
	
				if skill_change_style == 0{
					enemy_pos = get_world_position_from_grid(3,1)
				}
				else{
					enemy_pos = get_world_position_from_grid(3,5)
				}
	
				x = enemy_pos.x - 90
				y = enemy_pos.y + 30
				image_alpha = 1
			}
		}
		
		else if jump_times == 1{
			if skill_timer == 24+37 * 5 - 1{
				var inst = instance_create_depth(x-120,y-30,-10,obj_coke_bomb_explode)
				inst.sprite_index = spr_xiaoming_ice
				var erase_col = grid_col - 1
				var erase_row = grid_row
		
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
			}
			if skill_timer == 49*5+24{
				skill_timer = 0
				jump_times++
			}
		}
		
		if jump_times >= 2{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_huang_xiaoming_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 5
		}
		else{
			image_index = floor(timer /5) mod 5
		}
		
		x += x_move_speed
		y += y_move_speed
		if skill_change_style == 0{
			if timer == 1{
				var t_pos = get_world_position_from_grid(3,4)
				x_move_speed = (t_pos.x-x)/240
				y_move_speed = (t_pos.y+30-y)/240
			}
			if timer == 241{
				var t_pos = get_world_position_from_grid(5,2)
				x_move_speed = (t_pos.x-x)/120
				y_move_speed = (t_pos.y+30-y)/120
			}
			if timer == 361{
				var t_pos = get_world_position_from_grid(1,0)
				x_move_speed = (t_pos.x-x)/240
				y_move_speed = (t_pos.y+30-y)/240
			}
		}
		else if skill_change_style == 1{
			if timer == 1{
				var t_pos = get_world_position_from_grid(3,2)
				x_move_speed = (t_pos.x-x)/240
				y_move_speed = (t_pos.y+30-y)/240
			}
			if timer == 241{
				var t_pos = get_world_position_from_grid(5,4)
				x_move_speed = (t_pos.x-x)/120
				y_move_speed = (t_pos.y+30-y)/120
			}
			if timer == 361{
				var t_pos = get_world_position_from_grid(1,6)
				x_move_speed = (t_pos.x-x)/240
				y_move_speed = (t_pos.y+30-y)/240
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
		
		if timer >= 600{
			x_move_speed = 0
			y_move_speed = 0
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_huang_xiaoming_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/6) mod 2
		}
		else{
			image_index = floor(timer/6) mod 2
		}
		if timer == 2 * 6 - 1{
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
				if skill_change_style == 0{
					enemy_row = 5
				}
				else{
					enemy_row = 1
				}
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 0{
				if skill_change_style == 0{
					enemy_row = 0
				}
				else{
					enemy_row = 1
				}
				enemy_pos = get_world_position_from_grid(10,enemy_row)
			}
			else{
				if skill_change_style == 0{
					enemy_pos = get_world_position_from_grid(8,5)
				}
				else{
					enemy_pos = get_world_position_from_grid(8,1)
				}
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
		sprite_index = spr_huang_xiaoming_death
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

