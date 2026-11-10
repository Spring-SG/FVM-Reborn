if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

// 入场：第 9 列随机行（标准 9 列网格的 0-based 第 8 列）
if !appear{
	var _start = get_dest(global.grid_cols - 1, irandom_range(0, global.grid_rows - 1));
	x = _start.x
	y = _start.y
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
	target_plant = noone;	// 清除攻击目标
	global.enemy_damage_reduction = 0	// 技能3的减伤不随本体残留
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		sprite_index = spr_ufo_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.APPEAR:
		// 入场那次：完整播一遍出现动画，播完转入待机
		if first_appear{
			sprite_index = spr_ufo_mouse_appear
			image_index = min(floor(timer/5), 4)
			if timer == 5 * 5 - 1{
				timer = 0
				first_appear = false
				state = BOSS_STATE.IDLE
				break
			}
			break
		}
		// 技能中途的二次位移结束：回到正在执行的技能继续，不消耗技能轮转
		// （skill_step 0 = 还没进入技能，1 = 技能刚开始，2/3 = 技能中途的第 N 次位移）
		if skill_step >= 2{
			timer = 0
			state = get_skill_state(skill_phase)
			break
		}
		// 换技能：不播出现动画，直接把控制权交给对应技能
		timer = 0
		skill_phase = skill_count
		skill_count = (skill_count + 1) mod 3
		skill_step = 1
		state = get_skill_state(skill_phase)
		break
		
	case BOSS_STATE.SKILL1:
		sprite_index = spr_ufo_mouse_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 32
		}
		else{
			image_index = floor(timer/5) mod 32 + 32
		}
		
		// 光柱最强的第 21 帧，把当前格 3*3 内的卡片吸走
		if timer == 105{
			destroy_3x3(cell_col, cell_row)
		}
		
		// 一套动画打完（32 帧 * 5 tick）
		if timer >= 32 * 5{
			if skill_step == 2{
				// 两处都吸完了
				skill_step = 0
				timer = 0
				state = BOSS_STATE.IDLE
			}
			else{
				// 再挑一个不重复的格子，飞过去吸第二次
				var _try = 0
				var _next_col = cell_col
				var _next_row = cell_row
				while ((_next_col == cell_col && _next_row == cell_row) && _try < 100){
					_next_col = irandom_range(0, global.grid_cols - 2)
					_next_row = irandom_range(0, global.grid_rows - 2)
					_try++
				}
				cell_col = _next_col
				cell_row = _next_row
				
				var _d = get_dest(cell_col, cell_row)
				dest_x = _d.x
				dest_y = _d.y
				dest_ready = true
				move_time = 120
				skill_step = 2
				timer = 0
				state = BOSS_STATE.DISAPPEAR
			}
			break
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_ufo_mouse_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 32
		}
		else{
			image_index = floor(timer/5) mod 32 + 32
		}
		
		// 站在 0 列的预备段：抽好两列目标列就立刻飞向第一列
		// （1-based 第 3-7 列 -> 0-based 2-6）
		if skill_step == 1{
			if timer == 1{
				flame_col_1 = irandom_range(2, 6)
				flame_col_2 = irandom_range(2, 6)
				var _guard = 0
				while (flame_col_2 == flame_col_1 && _guard < 100){
					flame_col_2 = irandom_range(2, 6)
					_guard++
				}
			}
			if timer == 20{
				// 喷火管很长：本体要站在目标列左侧 3 列，火焰才刚好落在目标列
				var _d = get_dest(flame_col_1 - 3, burn_row)
				dest_x = _d.x
				dest_y = _d.y
				dest_ready = true
				move_time = 60
				skill_step = 2
				timer = 0
				state = BOSS_STATE.DISAPPEAR
				break
			}
			break
		}
		
		// 火焰从第 105 tick 起，从上往下一行一行喷出来（每 4 tick 一行）
		if timer >= flame_start{
			var _fcol = flame_col_1
			if skill_step == 3{
				_fcol = flame_col_2
			}
			var _elapsed = timer - flame_start
			if (_elapsed mod flame_step) == 0{
				var _frow = _elapsed div flame_step
				if _frow < global.grid_rows{
					spawn_flame_cell(_fcol, _frow)
				}
			}
		}
		
		if timer >= 32 * 5{
			if skill_step == 3{
				// 两列都点完了
				skill_step = 0
				timer = 0
				state = BOSS_STATE.IDLE
			}
			else{
				// 飞到第二列的喷火位置
				var _d = get_dest(flame_col_2 - 3, burn_row)
				dest_x = _d.x
				dest_y = _d.y
				dest_ready = true
				move_time = 60
				skill_step = 3
				timer = 0
				state = BOSS_STATE.DISAPPEAR
			}
			break
		}
		break
		
	case BOSS_STATE.SKILL3:
		sprite_index = spr_ufo_mouse_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		
		// 全场除 BOSS 外的老鼠减伤 90%，持续 8 秒（480 帧）
		if timer == 10{
			global.enemy_damage_reduction = 0.9
		}
		if timer >= 10 + 480{
			global.enemy_damage_reduction = 0
			skill_step = 0
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		// 飞碟鼠没有移动动画，用闲置动画代替
		sprite_index = spr_ufo_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		
		if timer == 1{
			var _d = undefined
			positioning = !dest_ready
			// 技能没指定落点时，按"下一个要放的技能"自行定位
			if positioning{
				if skill_count == 0{
					// 技能1：随机跳到 1-8 列、1-6 行里的一格
					cell_col = irandom_range(0, global.grid_cols - 2)
					cell_row = irandom_range(0, global.grid_rows - 2)
					_d = get_dest(cell_col, cell_row)
					move_time = 90
				}
				else if skill_count == 1{
					// 技能2：先飞到 4 行 0 列
					_d = get_dest(0, 3)
					move_time = 90
				}
				else{
					// 技能3：飞到 4 行 5 列
					_d = get_dest(4, 3)
					move_time = 120
				}
				dest_x = _d.x
				dest_y = _d.y
			}
			dest_ready = false
			move_dx = (dest_x - x) / move_time
			move_dy = (dest_y - y) / move_time
		}
		if timer >= 1 && timer < move_time{
			x += move_dx
			y += move_dy
		}
		if timer >= move_time{
			x = dest_x
			y = dest_y
			timer = 0
			// 贴图朝向在"技能开始前那次移动"结束之后才翻转：
			// 技能2 喷火管朝右（-1.8），技能1/技能3 恢复朝左（1.8）
			if positioning{
				if skill_count == 1{
					image_xscale = -1.8
				}
				else{
					image_xscale = 1.8
				}
				positioning = false
			}
			state = BOSS_STATE.APPEAR
		}
		break
		
	case BOSS_STATE.DEATH:
		sprite_index = spr_ufo_mouse_death
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