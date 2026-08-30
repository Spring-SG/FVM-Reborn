if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var ap_pos = get_world_position_from_grid(10,1)
	x = ap_pos.x-90
	y = ap_pos.y+30
	image_alpha = 1
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 1000
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
}
//移动阶段处理
if move_stage == 0 && x <= get_world_position_from_grid(5,1).x{
	move_stage = 1
}
if move_stage == 1 && y >= get_world_position_from_grid(5,3).y + 30{
	move_stage = 2
}
if move_stage == 2 && x <= get_world_position_from_grid(2,3).x{
	move_stage = 3
}
if move_stage == 3 && y >= get_world_position_from_grid(2,6).y + 30{
	move_stage = 4
}

switch state{
	case BOSS_STATE.IDLE:
		if move_stage == 0 || move_stage == 2 || move_stage == 4{
			x -= move_speed
		}
		else{
			y += move_speed
		}
		sprite_index = spr_thor_body_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
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
		if timer >= wait_time{
			timer = 0
			if skill_count == 0{
				state = BOSS_STATE.SKILL1
				skill_count ++
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL2
				skill_count ++
			}
			else{
				state = BOSS_STATE.SKILL3
				skill_count = 0
			}
			wait_time = 18 * 60
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_mario_mouse_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 13
		}
		else{
			image_index = floor(timer/5) mod 13 + 13
		}
		if timer == 13 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_thor_body_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 14
		}
		else{
			image_index = floor(timer/5) mod 14 + 14
		}
		
		if timer == 7 * 5 + 2{
			var m_pos = get_world_position_from_grid(grid_col,clamp(grid_row,0,global.grid_rows-1))
			instance_create_depth(m_pos.x+10,m_pos.y+38,-800,obj_wrestler_mouse)
		}
		
		if timer >= 14 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_thor_body_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 30
		}
		else{
			image_index = floor(timer/5) mod 30 + 30
		}
		
		if timer == 19 * 5 + 2{
			var laser = instance_create_depth(x-45,y-120,-800,obj_coke_bomb_explode)
			laser.sprite_index = spr_thor_laser_left
			with obj_card_parent{
				if grid_row == other.grid_row - 1 &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
		}
		
		if timer >= 30 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		sprite_index = spr_thor_body_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 23
		}
		else{
			image_index = floor(timer/5) mod 23 + 23
		}
		
		if timer == 17 * 5 + 2{
			var laser1 = instance_create_depth(x+5,y-15,-800,obj_coke_bomb_explode)
			laser1.sprite_index = spr_thor_laser_down
			var laser2 = instance_create_depth(x+5,y-120,-800,obj_coke_bomb_explode)
			laser2.sprite_index = spr_thor_laser_up
			with obj_card_parent{
				if grid_col== other.grid_col &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
		}
		
		if timer >= 23 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_mario_mouse_dig_down
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 18
		}
		else{
			image_index = floor(timer/5) mod 18 + 18
		}
		if timer == 18 * 5 - 1{
			image_alpha = 0
		}
		if timer == 210{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = get_world_position_from_grid(10,enemy_row)
			x = enemy_pos.x - 80
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_thor_body_death
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

if x < global.grid_offset_x-150 && hp > 0{
	global.is_paused = true
	global.game_over = true
	instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
	audio_play_sound(snd_lose,0,0)
}