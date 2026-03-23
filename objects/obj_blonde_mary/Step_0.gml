if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	if skill_count == 1 || skill_count == 3{
		enemy_pos = get_world_position_from_grid(9,3)
	}
	else{
		enemy_pos = get_world_position_from_grid(4,enemy_row)
	}
	x = enemy_pos.x - 80
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
		sprite_index = spr_blonde_mary_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer >= wait_time{
			timer = 0
			
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_blonde_mary_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 17
		}
		else{
			image_index = floor(timer/5) mod 17 + 17
		}
		if timer == 1{
			with obj_card_parent{
				if grid_row == other.grid_row && grid_col == other.grid_col && plant_id != "player" && plant_type != "coffee"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		if timer == 17 * 5 - 1{
			timer = 0
			if skill_count == 0 || skill_count == 2{
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
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
		if timer <= 90{ 
			sprite_index = spr_blonde_mary_skill_1_forward
		}
		else{
			sprite_index = spr_blonde_mary_skill_1_backward
		}
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		
		var target_col = abs(3 - jump_times)
		if timer <= 90{
			x -= 4
		}
		else{
			x += 4
		}
		if timer == 20*jump_times + 1 && target_col < 4{
			with obj_card_parent{
				if grid_col == target_col && grid_row == other.grid_row && plant_id != "player" && plant_type != "coffee"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
			jump_times++
		}
		if timer >= 180{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL2:
		if timer <= 5*5 - 1{
		
			sprite_index = spr_blonde_mary_skill_2_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 5
			}
			else{
				image_index = floor(timer /5) mod 5 + 5
			}
		}
		else{
			sprite_index = spr_blonde_mary_skill_2
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 6
			}
			else{
				image_index = floor(timer /5) mod 6 + 6
			}
		}
		
		if timer == 5 * 5 - 1{
			awake_card_id_list = []
			with obj_card_parent{
				if state != CARD_STATE.SLEEP{
					state = CARD_STATE.SLEEP
					array_push(other.awake_card_id_list,id)
				}
			}
		}
		if timer >= 325{
			with obj_card_parent{
				if array_get_index(other.awake_card_id_list,id) != -1{
					state = CARD_STATE.IDLE
				}
			}
			awake_card_id_list = []
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_blonde_mary_skill_3
		if timer <= 7 * 5 - 1{
			image_index = (timer/5) mod 7
		}
		else if timer <= 7 * 5 + 130{
			image_index = (timer/5) mod 7 + 7
		}
		else{
			image_index = ((timer-165)/5) mod 5 + 14
		}
		if hp <= maxhp * hurt_rate{
			image_index += 19
		}
		
		if timer == 6 * 5 - 2{
			var inst = instance_create_depth(x+45,y-45,-800,obj_blonde_mary_bullet)
			inst.center_x = x - 214
			inst.center_y = y - 60
		}
		if timer >= 165+5*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_blonde_mary_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 18
		}
		else{
			image_index = floor(timer/5) mod 18 + 18
		}
		if timer == 18 * 5 - 1{
			image_alpha = 0
		}
		if timer == 240{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 1{
				enemy_pos = get_world_position_from_grid(9,3)
			}
			else if skill_count == 3{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(4,enemy_row)
			}
			x = enemy_pos.x - 80
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_blonde_mary_death
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

