if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	// 首次出场：第 9 列（落点带 -90，传 9 实际站到 1 基的第 9 列）的随机行
	var start_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = get_world_position_from_grid(9,start_row)
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	skill1_row = start_row
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 1000
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
		sprite_index = spr_tribal_chief_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.APPEAR:
		// 到位后的待机，一轮动画播完再按循环决定释放哪个技能
		sprite_index = spr_tribal_chief_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer == 10 * 5 - 1{
			timer = 0
			if skill_count == 0{
				skill1_phase = 0
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL3
			}
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		// 技能1：冲刺碾压整行。左冲——返回动作——翻面待机——纵向换行——右冲
		switch skill1_phase{
			case 0:
				// 准备动作
				sprite_index = spr_tribal_chief_mouse_skill_1_ready
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 12
				}
				else{
					image_index = floor(timer/5) mod 12 + 12
				}
				if timer >= 12 * 5-1{
					timer = 0
					skill1_phase = 1
					dash_target_x = get_world_position_from_grid(0,skill1_row).x - 90
					x_move_speed = (dash_target_x - x) / 60
				}
				break
				
			case 1:
				// 向左冲刺
				sprite_index = spr_tribal_chief_mouse_skill_1
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 9
				}
				else{
					image_index = floor(timer/5) mod 9 + 9
				}
				x += x_move_speed
				// 碾碎本行路径上的卡片，每张扣除自身 0.25% 最大生命
				with obj_card_parent{
					if grid_row == other.skill1_row && abs(x - other.x) <= 60
					&& !invincible && plant_id != "player" && plant_type != "coffee"
					&& plant_id != "cotton_candy" && plant_id != "soda_bubble"{
						if hp >= max_hp{
							obj_task_manager.card_loss ++
						}
						instance_destroy()
						other.hp -= other.maxhp * other.skill1_card_damage_rate
					}
				}
				if x <= dash_target_x || timer >= 60{
					x = dash_target_x
					timer = 0
					skill1_phase = 2
				}
				break
				
			case 2:
				// 撞到左侧后的返回/收势动作
				sprite_index = spr_tribal_chief_mouse_skill_1_return
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 12
				}
				else{
					image_index = floor(timer/5) mod 12 + 12
				}
				if timer >= 12 * 5-1{
					timer = 0
					skill1_phase = 3
					image_xscale = -1.8		// 贴图水平翻转，朝向右侧
				}
				break
				
			case 3:
				// 翻面后原地待机
				sprite_index = spr_tribal_chief_mouse_idle
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 10
				}
				else{
					image_index = floor(timer/5) mod 10 + 10
				}
				if timer >= 60{
					timer = 0
					skill1_phase = 4
					skill1_row = irandom_range(0,global.grid_rows-1)
					y_move_speed = (get_world_position_from_grid(0,skill1_row).y + 30 - y) / 60
				}
				break
				
			case 4:
				// 纵向移动到随机行
				sprite_index = spr_tribal_chief_mouse_move
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 10
				}
				else{
					image_index = floor(timer/5) mod 10 + 10
				}
				y += y_move_speed
				if timer >= 60{
					y = get_world_position_from_grid(0,skill1_row).y + 30
					timer = 0
					skill1_phase = 5
				}
				break
				
			case 5:
				// 向右冲刺前的准备动作
				sprite_index = spr_tribal_chief_mouse_skill_1_ready
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 12
				}
				else{
					image_index = floor(timer/5) mod 12 + 12
				}
				if timer >= 12 * 5-1{
					timer = 0
					skill1_phase = 6
					dash_target_x = get_world_position_from_grid(9,skill1_row).x - 90
					x_move_speed = (dash_target_x - x) / 60
				}
				break
				
			case 6:
				// 向右冲刺回第 9 列（贴图已翻转，朝向右侧）
				sprite_index = spr_tribal_chief_mouse_skill_1
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 9
				}
				else{
					image_index = floor(timer/5) mod 9 + 9
				}
				x += x_move_speed
				// 同样碾碎本行路径上的卡片
				with obj_card_parent{
					if grid_row == other.skill1_row && abs(x - other.x) <= 60
					&& !invincible && plant_id != "player" && plant_type != "coffee"
					&& plant_id != "cotton_candy" && plant_id != "soda_bubble"{
						if hp >= max_hp{
							obj_task_manager.card_loss ++
						}
						instance_destroy()
						other.hp -= other.maxhp * other.skill1_card_damage_rate
					}
				}
				if x >= dash_target_x || timer >= 60{
					x = dash_target_x
					timer = 0
					skill1_phase = 7
				}
				break
				
			case 7:
				// 撞到右侧后的返回/收势动作
				sprite_index = spr_tribal_chief_mouse_skill_1_return
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 12
				}
				else{
					image_index = floor(timer/5) mod 12 + 12
				}
				if timer >= 12 * 5-1{
					timer = 0
					skill1_phase = 8
					image_xscale = 1.8		// 收势结束后把贴图翻转回来
				}
				break
				
			case 8:
				// 收尾待机
				sprite_index = spr_tribal_chief_mouse_idle
				if hp > maxhp * hurt_rate{
					image_index = floor(timer/5) mod 10
				}
				else{
					image_index = floor(timer/5) mod 10 + 10
				}
				if timer >= 30{
					timer = 0
					skill1_phase = 0
					state = BOSS_STATE.IDLE
				}
				break
		}
		break
		
	case BOSS_STATE.SKILL2:
		// 技能2：图腾砸击，摧毁落点为中心的 3*3 卡片
		// skill2_row = 2（1 基第 3 行）时向上砸，skill2_row = 4（1 基第 5 行）时向下砸
		var aim_up = (skill2_row <= 2)
		if aim_up{
			sprite_index = spr_tribal_chief_mouse_skill_2_up
			skill2_target_row = 1		// 1 基第 2 行
		}
		else{
			sprite_index = spr_tribal_chief_mouse_skill_2_down
			skill2_target_row = 5		// 1 基第 6 行
		}
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 27
		}
		else{
			image_index = floor(timer/5) mod 27 + 27
		}
		
		if timer == 13 * 5{
			with obj_card_parent{
				if abs(grid_row - other.skill2_target_row) <= 1 && abs(grid_col - other.skill2_target_col) <= 1
				&& !invincible && plant_id != "player" && plant_type != "coffee"
				&& plant_id != "cotton_candy" && plant_id != "soda_bubble"{
					if hp >= max_hp{
						obj_task_manager.card_loss ++
					}
					instance_destroy()
				}
			}
			global.audio.play(snd_coke_bomb_explode,0,0)
			if global.screen_shake{
				Camera_Shock(6,22)
			}
		}
		
		if timer >= 27 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		// 技能3：冰封前方 3*3 范围的卡片 600 帧
		sprite_index = spr_tribal_chief_mouse_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 19
		}
		else{
			image_index = floor(timer/5) mod 19 + 19
		}
		
		if timer == 8 * 5{
			var boss_grid = get_grid_position_from_world(x,y)
			var boss_row = boss_grid.row
			var boss_col = boss_grid.col
			with obj_card_parent{
				if abs(grid_row - boss_row) <= 1
				&& grid_col < boss_col && grid_col >= boss_col - other.skill3_front_cols
				&& plant_id != "player" && plant_type != "coffee" && !invincible{
					// 冰冻时长不做加法：低于该值的直接补到该值
					if frozen_timer < other.skill3_freeze_time{
						frozen_timer = other.skill3_freeze_time
					}
				}
			}
		}
		
		if timer >= 19 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		// 移动：按 skill_count 决定下一个技能的站位（所有位移都在这里做）
		sprite_index = spr_tribal_chief_mouse_move
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer == 1{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 0{
				// 技能1：第 9 列（落点带 -90，传 9 实际站到 1 基的第 9 列）随机行
				skill1_row = enemy_row
				enemy_pos = get_world_position_from_grid(9,skill1_row)
			}
			else if skill_count == 1{
				// 技能2：1 基第 3 行或第 5 行（0 基 2 / 4）的第 9 列
				skill2_row = choose(2,4)
				skill2_row = clamp(skill2_row,0,global.grid_rows-1)
				enemy_pos = get_world_position_from_grid(9,skill2_row)
			}
			else{
				// 技能3：第 9 列随机行
				skill3_row = enemy_row
				enemy_pos = get_world_position_from_grid(9,skill3_row)
			}
			x_move_speed = (enemy_pos.x - 90 - x)/90
			y_move_speed = (enemy_pos.y + 30 - y)/90
		}
		if timer >= 1 && timer <= 90{
			x += x_move_speed
			y += y_move_speed
		}
		if timer == 90{
			image_xscale = 1.8
			timer = 0
			state = BOSS_STATE.APPEAR
		}
		break
		
	case BOSS_STATE.DEATH:
		sprite_index = spr_tribal_chief_mouse_death
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