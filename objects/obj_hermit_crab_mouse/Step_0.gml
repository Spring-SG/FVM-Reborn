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
		image_xscale = -1.8
	}
	else if skill_count == 0{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
		image_xscale = 1.8
	}
	else{
		enemy_pos = get_world_position_from_grid(1,enemy_row)
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
	global.save_data.player.gold += 3000
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
		sprite_index = idle_spr
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer >= wait_time{
			timer = 0
			if skill_count == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL1
			}
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
			
			
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_hermit_crab_mouse_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 25
		}
		else{
			image_index = floor(timer/5) mod 25 + 25
		}
		if timer == 25 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_hermit_crab_mouse_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 27
		}
		else{
			image_index = floor(timer/5) mod 27 + 27
		}
		
		// ===== 技能1实战效果：第2~6列（代码索引1~5）全行中随机摧毁3个不重复格子的卡片 =====
		// 第7帧（timer = 7*5）为动画开始爆发的时刻
		if timer == 7 * 5{
			// 枚举候选格子（1~5列 × 全行），洗牌后取前3个，天然保证不重复
			var _cells = [];
			var _max_col = min(5, global.grid_cols - 1);
			for (var _c = 1; _c <= _max_col; _c++){
				for (var _r = 0; _r < global.grid_rows; _r++){
					array_push(_cells, [_c, _r]);
				}
			}
			shuffle_array(_cells);
			
			var _pick_count = min(3, array_length(_cells));
			var _cell_col = 0;
			var _cell_row = 0;
			var _cell_pos = undefined;
			var _hit_effect = noone;
			for (var _n = 0; _n < _pick_count; _n++){
				_cell_col = _cells[_n][0];
				_cell_row = _cells[_n][1];
				_cell_pos = get_world_position_from_grid(_cell_col, _cell_row);
				
				// 摧毁该格子上的卡片
				with obj_card_parent{
					if grid_col == _cell_col && grid_row == _cell_row && plant_id != "player"{
						if hp >= max_hp{
							obj_task_manager.card_loss++;
						}
						instance_destroy();
					}
				}
				
				// 该格子的落石/爆炸表现
				_hit_effect = instance_create_depth(_cell_pos.x, _cell_pos.y, calculate_plant_depth(_cell_col, _cell_row, "normal"), obj_coke_bomb_explode);
				_hit_effect.sprite_index = spr_hermit_crab_mouse_bullet;
			}
		}
		
		if timer >= 27*5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL2:
	
		sprite_index = spr_hermit_crab_mouse_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 30
		}
		else{
			image_index = floor(timer/5) mod 30 + 30
		}
		
		// ===== 技能2实战效果：落地瞬间（第27帧）摧毁以自身为中心的3*3格内所有卡片 =====
		if timer == 27 * 5{
			var _center_col = clamp(grid_col, 0, global.grid_cols - 1);
			var _center_row = clamp(grid_row, 0, global.grid_rows - 1);
			var _area_col = 0;
			var _area_row = 0;
			for (var _dc = -1; _dc <= 1; _dc++){
				for (var _dr = -1; _dr <= 1; _dr++){
					_area_col = _center_col + _dc;
					_area_row = _center_row + _dr;
					// 越界格子跳过
					if (_area_col < 0 || _area_col >= global.grid_cols || _area_row < 0 || _area_row >= global.grid_rows){
						continue;
					}
					// 摧毁该格子上的卡片
					with obj_card_parent{
						if grid_col == _area_col && grid_row == _area_row && plant_id != "player"{
							if hp >= max_hp{
								obj_task_manager.card_loss++;
							}
							instance_destroy();
						}
					}
				}
			}
		}
		
		if timer >= 30*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		if timer <= 17 * 5 - 1{
			sprite_index = spr_hermit_crab_mouse_disappear
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 17
			}
			else{
				image_index = floor(timer/5) mod 17 + 17
			}
		}
		else{
			sprite_index = spr_hermit_crab_mouse_move
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 9
			}
			else{
				image_index = floor(timer/5) mod 9 + 9
			}
		}
		if timer == 17 * 5 - 1{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			if skill_count == 2{
				t_pos = get_world_position_from_grid(1,enemy_row)
			}
			else if skill_count == 0{
				t_pos = get_world_position_from_grid(9,enemy_row)
			}
			else{
				t_pos = get_world_position_from_grid(5,3)
			}
			x_move = (t_pos.x-90-x) / 120
			y_move_speed = (t_pos.y+30-y) / 120
		}
		if timer > 17 * 5 - 1 && timer < 120 + 17 * 5 - 1{
			x += x_move
			y += y_move_speed
		}
		if timer == 120 + 17 * 5 - 1{
			var enemy_pos = t_pos
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			if skill_count == 2{
				image_xscale = -1.8
			}
			if skill_count == 0{
				image_xscale = 1.8
			}
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_hermit_crab_mouse_death
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

