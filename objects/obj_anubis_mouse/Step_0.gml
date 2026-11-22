if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_pos = get_world_position_from_grid(10,irandom_range(0,global.grid_rows-1))
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
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
		sprite_index = spr_anubis_mouse_idle
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
		sprite_index = spr_anubis_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer == 10 * 5 - 1{
			timer = 0
			// 技能切换
			if skill_count == 0{
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
		sprite_index = spr_anubis_mouse_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 31
		}
		else{
			image_index = floor(timer/5) mod 31 + 31
		}
		
		// 若贴图还处于水平翻转状态，翻回正面
		if image_xscale < 0{
			image_xscale = 1.8
		}
		
		if timer == 20 * 5{
			// 三个 3*3 睡眠领域，中心分别为 4行4列 / 2行8列 / 6行8列（此处行列从 0 开始）
			var center_list = [[3,3],[1,7],[5,7]]
			for(var i = 0 ; i < array_length(center_list) ; i++){
				var center_row = clamp(center_list[i][0],0,global.grid_rows-1)
				var center_col = clamp(center_list[i][1],0,global.grid_cols-1)
				var center_pos = get_world_position_from_grid(center_col,center_row)
				// 深度 0：铺在卡片（-10 ~ -330）之下，不遮挡卡片
				var field_inst = instance_create_depth(center_pos.x,center_pos.y-10,-800,obj_anubis_mouse_skill_1_effect)
				field_inst.grid_row = center_row
				field_inst.grid_col = center_col
			}
		}
		
		if timer >= 31 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_anubis_mouse_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 15
		}
		else{
			image_index = floor(timer /5) mod 15 + 15
		}
		
		if timer == 12 * 5{
			// 随机挑 6 个互不重复的格子
			var cell_list = []
			var try_count = 0
			while array_length(cell_list) < 6 && try_count < 300{
				try_count ++
				var rand_col = irandom_range(0,global.grid_cols-1)
				var rand_row = irandom_range(0,global.grid_rows-1)
				var is_repeat = false
				for(var i = 0 ; i < array_length(cell_list) ; i++){
					if cell_list[i][0] == rand_col && cell_list[i][1] == rand_row{
						is_repeat = true
						break
					}
				}
				if !is_repeat{
					array_push(cell_list,[rand_col,rand_row])
				}
			}
			
			for(var i = 0 ; i < array_length(cell_list) ; i++){
				var cell_col = cell_list[i][0]
				var cell_row = cell_list[i][1]
				var cell_pos = get_world_position_from_grid(cell_col,cell_row)
				// 摧毁该格子上的卡片
				with obj_card_parent{
					if grid_col == cell_col && grid_row == cell_row &&
					plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy" && plant_id != "soda_bubble"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
				var explode_inst = instance_create_depth(cell_pos.x,cell_pos.y,-800,obj_coke_bomb_explode)
				explode_inst.sprite_index = spr_anubis_mouse_skill_2_effect
			}
		}
		
		if timer >= 30 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		sprite_index = spr_anubis_mouse_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 26
		}
		else{
			image_index = floor(timer /5) mod 26 + 26
		}
		
		if timer == 20 * 5{
			// 在第 6 列召唤一列原始巨人鼠（第 6 列 = 下标 5，x 再 +25）
			for(var i = 0 ; i < global.grid_rows ; i++){
				var summon_pos = get_world_position_from_grid(5,i)
				instance_create_depth(summon_pos.x + 25,summon_pos.y + 38,0,obj_primordial_giant_mouse)
			}
		}
		
		if timer >= 26 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_anubis_mouse_move
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer == 1{
			// 按下一个要放的技能决定落点
			// 注意：列下标用的是"设置列"，因为下面算坐标时 x 会 -90（约 0.84 格），
			// 实际落点正好是设置列的左侧一格，即下标 N 本体落在 0-based 第 N-1 列
			var enemy_pos = {}
			if skill_count == 0{
				// 技能1：随机行第 9 列
				enemy_pos = get_world_position_from_grid(9,irandom_range(0,global.grid_rows-1))
			}
			else if skill_count == 1{
				// 技能2：随机行第 7 列
				enemy_pos = get_world_position_from_grid(7,irandom_range(0,global.grid_rows-1))
			}
			else{
				// 技能3：第 4 行第 0 列（最左侧一格）
				// 列取 1 是为了抵消 x-90 的偏移：下标 1 的实际落点是 0-based 第 0 列
				enemy_pos = get_world_position_from_grid(0,3)
			}
			x_move_speed = (enemy_pos.x - 90 - x)/180
			y_move_speed = (enemy_pos.y + 30 - y)/180
		}
		if timer >= 1 && timer <= 180{
			x += x_move_speed
			y += y_move_speed
		}
		if timer == 180{
			// 技能3需要面向右侧（水平翻转），其它技能保持正面
			if skill_count == 2{
				image_xscale = -1.8
			}
			else{
				image_xscale = 1.8
			}
			timer = 0
			state = BOSS_STATE.APPEAR
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_anubis_mouse_death
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
