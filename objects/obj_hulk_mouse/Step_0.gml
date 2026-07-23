if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_pos = get_world_position_from_grid(12,3)
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	image_alpha = 1
	var target_x = get_world_position_from_grid(8,3).x
	x_move_speed = (target_x-x)/120
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
	skill_choose = -1
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
		sprite_index = spr_hulk_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 9
		}
		else{
			image_index = floor(timer/5) mod 9 + 9
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
		sprite_index = spr_hulk_mouse_appear
		if timer <= 120{
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 8
			}
			else{
				image_index = floor(timer/5) mod 8 + 80
			}
			x += x_move_speed
		}
		else{
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-120)/5) mod 72 + 8
			}
			else{
				image_index = floor((timer-120)/5) mod 72 + 88
			}
		}
		if timer == 120 + 72 * 5 - 1{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
	case BOSS_STATE.SKILL1:
		if timer <= 8 * 5 - 1{
			sprite_index = spr_hulk_mouse_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 8
			}
			else{
				image_index = floor(timer /5) mod 8 + 8
			}
		}
		else if timer <= 95{
			sprite_index = spr_hulk_mouse_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-8*5) /3) mod 7
			}
			else{
				image_index = floor((timer-8*5) /3) mod 7
			}
			x -= 10
		}
		else if timer <= 95 + 8 * 5 - 1{
			sprite_index = spr_hulk_mouse_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = 8 - (floor((timer-95) /5) mod 8)
			}
			else{
				image_index = 16 - (floor((timer-95) /5) mod 8)
			}
		}
		else if timer <= 95 + 20 * 5 - 1{
			sprite_index = spr_hulk_mouse_move_fast
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-135) /5) mod 12
			}
			else{
				image_index = floor((timer-135) /5) mod 12 + 12
			}
		}
		else if timer <= 95 + 28 * 5 - 1{
			sprite_index = spr_hulk_mouse_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-195)/5) mod 8
			}
			else{
				image_index = floor((timer-195)/5) mod 8 + 8
			}
		}
		else if timer <= 150 + 28 * 5 - 1{
			sprite_index = spr_hulk_mouse_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-235) /3) mod 7
			}
			else{
				image_index = floor((timer-235) /3) mod 7
			}
			x -= 10
		}
		else if timer <= 150 + 36 * 5 - 1{
			sprite_index = spr_hulk_mouse_skill_1_ready
			if hp > maxhp * hurt_rate{
				image_index = 8 - (floor((timer-290) /5) mod 8)
			}
			else{
				image_index = 16 - (floor((timer-290) /5) mod 8)
			}
		}
		
		if sprite_index == spr_hulk_mouse_skill_1 && grid_col <= 5{
			with obj_card_parent{
				if grid_col >= other.grid_col-1 && grid_col <= other.grid_col && grid_row >= other.grid_row-1 && grid_row <= other.grid_row &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
		}
		
		if timer == 95 + 12 * 5 - 1{
			var enemy_pos = get_world_position_from_grid(7,skill_1_row[1])
			x_move_speed = (enemy_pos.x - 90 - x)/20
			y_move_speed = (enemy_pos.y + 30 - y)/20
		}
		if timer > 95 + 13 * 5 - 1 && timer <= 95 + 17 * 5 - 1{
			x += x_move_speed
			y += y_move_speed
		}
		
		if timer >= 150 + 36 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_hulk_mouse_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 23
		}
		else{
			image_index = floor(timer /5) mod 23 + 23
		}
		
		if timer == 9 * 5 + 2{
			for(var i = 0 ; i < 5 ; i++){
				var erase_col = skill_2_erase_pos[i][0]
				var erase_row = skill_2_erase_pos[i][1]
				var erase_pos = get_world_position_from_grid(erase_col,erase_row)
				var effect_inst = instance_create_depth(erase_pos.x,erase_pos.y,-800,obj_coke_bomb_explode)
				effect_inst.sprite_index = spr_hulk_mouse_skill_effect_2
				with obj_card_parent{
					if grid_col == erase_col && grid_row == erase_row &&
					plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
			}
		}
		
		if timer >= 23*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	case BOSS_STATE.SKILL3:
		
		if timer <= 49 * 5 - 1{
			sprite_index = spr_hulk_mouse_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 49
			}
			else{
				image_index = floor(timer /5) mod 49 + 49
			}
		}
		else if timer <= 61 * 5 - 1{
			sprite_index = spr_hulk_mouse_move_fast
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-49*5) /5) mod 12
			}
			else{
				image_index = floor((timer-49*5) /5) mod 12 + 12
			}
		}
		else if timer <= 110 * 5 - 1{
			sprite_index = spr_hulk_mouse_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-61*5) /5) mod 49
			}
			else{
				image_index = floor((timer-61*5) /5) mod 49 + 49
			}
		}
		
		if timer == 49 * 5 + 4 * 5 - 1{
			var enemy_pos = get_world_position_from_grid(9,global.grid_rows-1)
			x_move_speed = (enemy_pos.x - 90 - x)/20
			y_move_speed = (enemy_pos.y + 30 - y)/20
		}
		if timer > 49 * 5 + 5 * 5 - 1 && timer <= 49 * 5 + 9 * 5 - 1{
			x += x_move_speed
			y += y_move_speed
		}
		if timer == 23 * 5 + 2 || timer == 61*5 + 23 * 5 + 2{
			var effect_pos = get_world_position_from_grid(6,grid_row)
			var effect_inst = instance_create_depth(effect_pos.x,effect_pos.y,-800,obj_hulk_destroy_effect)
			effect_inst.target_row = grid_row
			effect_inst.target_col = 6
		}
		
		if timer >= 110*5-1{
			jump_times = 0
			skill_timer = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_hulk_mouse_move_slow
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 15
		}
		else{
			image_index = floor(timer/5) mod 15 + 15
		}
		//if timer == 11 * 5 - 1{
		//	image_alpha = 0
		//}
		if timer == 1{
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
				enemy_row = 2
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 0{
				skill_1_row[0] = irandom_range(1,2)
				skill_1_row[1] = irandom_range(4,global.grid_rows-1)
				enemy_pos = get_world_position_from_grid(7,skill_1_row[0]) 
			}
			else{
				enemy_row = 3
				enemy_pos = get_world_position_from_grid(7,enemy_row)
			}
			x_move_speed = (enemy_pos.x - 90 - x)/30
			y_move_speed = (enemy_pos.y + 30 - y)/30
		}
		
		if timer > 5 * 5 - 1 && timer <= 11 * 5 - 1{
			x += x_move_speed
			y += y_move_speed
		}
		
		if timer == 15*5-1{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_choose == 2{
				enemy_row = 2
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 0{
				enemy_pos = get_world_position_from_grid(7,skill_1_row[0]) 
			}
			else{
				enemy_row = 3
				enemy_pos = get_world_position_from_grid(7,enemy_row)
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_hulk_mouse_death
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

