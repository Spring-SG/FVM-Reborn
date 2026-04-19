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
	image_alpha = 1
    target_plant = noone;  // 清除攻击目标
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		sprite_index = spr_lieutenant_buzz_idle
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
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 3{
				state = BOSS_STATE.SKILL4
			}
			skill_count ++
			if skill_count >= 4{
				skill_count = 0
			}
			break
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_lieutenant_buzz_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		image_alpha = timer/50
		if timer == 10 * 5 - 1{
			image_alpha = 1
			timer = 0
			if skill_count == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 3{
				state = BOSS_STATE.SKILL4
			}
			skill_count ++
			if skill_count >= 4{
				skill_count = 0
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_lieutenant_buzz_skill_1
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 9
		}
		else{
			image_index = floor(timer/5) mod 9 + 9
		}
		
		if timer == 1{
			for(var i = 0 ; i < global.grid_rows-1;i++){
				for(var j = 0 ; j < global.grid_cols-1;j++){
					var plant_list = ds_grid_get(global.grid_plants,j,i)
					if ds_list_size(plant_list) > 0{
						ds_list_add(avaliable_pos,{"col":j,"row":i})
					}
				}
			}
		}
		
		if timer mod 45 == 35{
			if ds_list_size(avaliable_pos) > 0{
				var i = irandom_range(0,ds_list_size(avaliable_pos)-1)
				var target_p = ds_list_find_value(avaliable_pos,i)
				var missile = instance_create_depth(x-60,y-180,-800,obj_buzz_wind)
				missile.target_col = target_p.col
				missile.row = target_p.row
				var target_f = get_world_position_from_grid(target_p.col,target_p.row)
				missile.move_speed = (target_f.x - missile.x)/90
				missile.cvspeed = -(target_f.y - missile.y)/90
				ds_list_delete(avaliable_pos,i)
			}
		}
		
		if timer >= 9 * 5 * 3 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL4:
		
		
		
		if timer <= 120{
			sprite_index = spr_lieutenant_buzz_idle
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 10
			}
			else{
				image_index = floor(timer /5) mod 10 + 10
			}
		}
		else{
			sprite_index = spr_lieutenant_buzz_idle
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-120) /5) mod 10
			}
			else{
				image_index = floor((timer-120) /5) mod 10 + 10
			}
		}
		
		
		if timer == 1{
			
			t_pos = get_world_position_from_grid(2,1)
			
			y_move_speed = (t_pos.y+33-y)/120
			x_move = (t_pos.x-90-x)/120
		}
		if timer == 240{
			t_pos = get_world_position_from_grid(10,irandom_range(0,global.grid_rows-1))
			
			y_move_speed = (t_pos.y+33-y)/120
			x_move = (t_pos.x-90-x)/120
		}
		if timer > 1 && timer <= 120{
			if timer mod 39 == 0{
				var se_pos = get_grid_position_from_world(x,y)
				instance_create_depth(se_pos.x,se_pos.y+33,-800,obj_paratrooper_mouse)
			}
			x += x_move
			y += y_move_speed
		}
		else if timer < 240{
			y -= 8
		}
		else{
			x = t_pos.x - 90
			y += y_move_speed
		}
		if timer >= 360{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		if timer <= 120{
			sprite_index = spr_lieutenant_buzz_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 10
			}
			else{
				image_index = floor(timer /5) mod 10 + 10
			}
		}
		else{
			sprite_index = spr_lieutenant_buzz_idle
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-120) /5) mod 10
			}
			else{
				image_index = floor((timer-120) /5) mod 10 + 10
			}
		}
		
		if timer == 1{
			
			t_pos = get_world_position_from_grid(2,grid_row)
			
			y_move_speed = (t_pos.y+33-y)/120
			x_move = (t_pos.x-90-x)/120
		}
		if timer == 240{
			t_pos = get_world_position_from_grid(10,irandom_range(0,global.grid_rows-1))
			
			y_move_speed = (t_pos.y+33-y)/120
			x_move = (t_pos.x-90-x)/120
		}
		if timer > 1 && timer <= 120{
			if timer mod 23 == 0{
				with obj_card_parent{
					if grid_row == other.grid_row && grid_col == 5 - other.jump_times && !invincible && plant_id != "player" && plant_type != "coffee"{
						if hp >= max_hp{
							obj_task_manager.card_loss ++
						}
						instance_destroy()
					}
				}
				var effect_pos = get_world_position_from_grid(6-jump_times,grid_row)
				var effect_inst = instance_create_depth(effect_pos.x,effect_pos.y+10,-800,obj_arno_bullet_effect)
				effect_inst.sprite_index = spr_buzz_bullet_effect
				jump_times ++
			}
			
			x += x_move
			y += y_move_speed
		}
		else if timer < 240{
			y += 8
		}
		else{
			x = t_pos.x - 90
			y += y_move_speed
		}
		
		if timer >= 360{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	case BOSS_STATE.SKILL2:
		
		if timer <= (10 * 5 - 1){
			sprite_index = spr_lieutenant_buzz_skill_2_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 10
			}
			else{
				image_index = floor(timer /5) mod 10 + 10
			}
		}
		else if timer <= 10*5+210*3-1{
			if jump_times < 3{
				skill_timer ++
				if skill_timer == 1{
					t_pos = get_world_position_from_grid(irandom_range(3,7),irandom_range(0,global.grid_rows-1))
			
					y_move_speed = (t_pos.y+33-y)/90
					x_move = (t_pos.x-80-x)/90
				}
				if skill_timer > 1 && skill_timer <= 90{
					x += x_move
					y += y_move_speed
				}
				if skill_timer == 91{
					instance_create_depth(x+40,y,-100,obj_apple_football_fan_mouse)
					t_pos = get_world_position_from_grid(9,irandom_range(0,global.grid_rows-1))
			
					y_move_speed = (t_pos.y+33-y)/90
					x_move = (t_pos.x-80-x)/90
				}
				if skill_timer > 120 && skill_timer <= 210{
					x += x_move
					y += y_move_speed
				}
				if skill_timer == 210 && jump_times < 3{
					skill_timer = 0
					jump_times++
				}
				
				if skill_timer < 90{
					sprite_index = spr_lieutenant_buzz_skill_2_catch
					if hp > maxhp * hurt_rate{
						image_index = floor((timer) /5) mod 10
					}
					else{
						image_index = floor((timer) /5) mod 10 + 10
					}
				}
				else{
					sprite_index = spr_lieutenant_buzz_skill_2
					if hp > maxhp * hurt_rate{
						image_index = floor((timer) /5) mod 10
					}
					else{
						image_index = floor((timer) /5) mod 10 + 10
					}
				}
			}
		}
		else{
			sprite_index = spr_lieutenant_buzz_skill_2_return
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-680) /5) mod 10
			}
			else{
				image_index = floor((timer-680) /5) mod 10 + 10
			}
		}
		
		if timer >= 20*5+210*3-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_pete_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 13
		}
		else{
			image_index = floor(timer/5) mod 13 + 13
		}
		if timer == 13 * 5 - 1{
			image_alpha = 0
		}
		if timer == 240{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 2{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_count == 0{
				enemy_pos = get_world_position_from_grid(irandom_range(2,6),enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(6,enemy_row)
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
		sprite_index = spr_lieutenant_buzz_death
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

