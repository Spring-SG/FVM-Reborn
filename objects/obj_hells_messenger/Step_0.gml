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
		enemy_pos = get_world_position_from_grid(10,enemy_row)
	}
	else if skill_count == 0{
		enemy_pos = get_world_position_from_grid(10,enemy_row)
	}
	else{
		enemy_pos = get_world_position_from_grid(10,enemy_row)
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
	global.save_data.player.gold += 1500
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
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 3{
				state = BOSS_STATE.SKILL4
			}
			else{
				state = BOSS_STATE.DISAPPEAR
			}
			skill_count ++
			if skill_count >= 5{
				skill_count = 0
			}
			
			
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_hells_messenger_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer == 6 * 5 - 1{
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
		sprite_index = spr_hells_messenger_skill_1
		if timer <= 9 * 5 * 3 - 1{
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 9
			}
			else{
				image_index = floor(timer/5) mod 9 + 25
			}
		}
		else{
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-135)/5) mod 16 + 9
			}
			else{
				image_index = floor((timer-135)/5) mod 16 + 34
			}
		}
		
		if timer == 1{
			for(var i = 0;i < 5 ; i++){
				var tg_row = irandom_range(0,global.grid_rows-1)
				var tg_y = get_world_position_from_grid(9,tg_row).y + 33
				var inst = instance_create_depth(x-20+10*i,y,-800,obj_messenger_ignis_fatuus)
				inst.y_move = (tg_y-y)/120
			}
		}
		
		if timer >= 43*5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL4:
		if timer <= 16*5 - 1{
		
			sprite_index = spr_hells_messenger_skill_4_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 16
			}
			else{
				image_index = floor(timer /5) mod 16 + 16
			}
		}
		else if timer <= 23*5-1{
			sprite_index = spr_hells_messenger_skill_4
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-80)/5) mod 7
			}
			else{
				image_index = floor((timer-80)/5) mod 7 + 7
			}
		}
		else{
			sprite_index = spr_hells_messenger_skill_2_ready
			if hp > maxhp * hurt_rate{
				image_index = 10 - floor((timer-115)/5) mod 10
			}
			else{
				image_index = (10 - floor((timer-115)/5) mod 10) + 10
			}
		}
		
		if timer == 1{
			var t_row = irandom_range(0,global.grid_rows-1)
			var t_col = irandom_range(1,5)
			t_pos = get_world_position_from_grid(t_col,t_row)
			x_move = (t_pos.x-100 - x)/80
			y_move_speed = (t_pos.y+30 - y)/80
		}
		if timer > 1 && timer <=80{
			x += x_move
			y += y_move_speed
		}
		if timer == 26 * 5 - 1{
			instance_create_depth(x+90,y,-800,obj_messenger_poop)
			with obj_card_parent{
				if(grid_col == other.t_pos.col && grid_row == other.t_pos.row && plant_id != "player" && plant_type != "coffee"){
					if hp >= max_hp{
						obj_task_manager.card_loss ++
					}
					instance_destroy()
				}
			}
		}
		if timer == 30 * 5 - 2{
			instance_destroy(obj_messenger_mace)
		}
		if timer >= 33*5 - 1{
			idle_spr = spr_hells_messenger_idle
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
	
		if timer <= 16 * 5 * 3 - 1{
			sprite_index = spr_hells_messenger_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 16
			}
			else{
				image_index = floor(timer /5) mod 16 + 16
			}
		}
		else{
			sprite_index = spr_hells_messenger_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer - 240)/5) mod 9
			}
			else{
				image_index = floor((timer - 240)/5) mod 9 + 9
			}
		}
		
		if timer == 1{
			ds_list_clear(avaliable_pos)
			for(var i = 0 ; i < global.grid_rows-1;i++){
				for(var j = 0 ; j < global.grid_cols-1;j++){
					var plant_list = ds_grid_get(global.grid_plants,j,i)
					if ds_list_size(plant_list) > 0{
						ds_list_add(avaliable_pos,{"col":j,"row":i})
					}
				}
			}

		}
		
		if timer == 16 * 5 * 3 + 30*jump_times && jump_times < 4{
			if ds_list_size(avaliable_pos) > 0{
				var pos_choose = irandom_range(0,ds_list_size(avaliable_pos)-1)
				var gr_pos = avaliable_pos[| pos_choose]
				with obj_card_parent{
					if plant_id != "player" && plant_type != "coffee" && !invincible
					&& grid_row == gr_pos.row && grid_col == gr_pos.col{
						var inst = instance_create_depth(x,y,-800,obj_card_inhale_effect)
						inst.x_move = (other.x - x)/120
						inst.y_move = (other.y-75-y)/120
						inst.sprite_index = sprite_index
						inst.image_index = image_index
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
				}
				ds_list_delete(avaliable_pos,pos_choose)
			}
			jump_times++
		}
		
		if timer >= 75*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_hells_messenger_skill_2_ready
		image_index = floor(timer /5) mod 10
		
		if hp <= maxhp * hurt_rate{
			image_index += 10
		}
		
		if timer == 7 * 5 - 2{
			var inst = instance_create_depth(x-75,y-45,-800,obj_messenger_mace)
			var target_pos = get_world_position_from_grid(4,3)
			inst.x_speed = (target_pos.x-inst.x)/120
			inst.y_speed = (target_pos.y-inst.y)/120
			inst.maxhp *= (1 + ((maxhp-30000)/30000)*0.5)
			inst.hp = inst.maxhp
		}
		
		if timer >= 10*5-1{
			idle_spr = spr_hells_messenger_skill_2_idle
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_hells_messenger_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 5
		}
		else{
			image_index = floor(timer/5) mod 5 + 5
		}
		if timer == 5 * 5 - 1{
			image_alpha = 0
		}
		if timer == 240{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 2{
				enemy_pos = get_world_position_from_grid(10,enemy_row)
			}
			else if skill_count == 0{
				enemy_pos = get_world_position_from_grid(10,enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(10,enemy_row)
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
		sprite_index = spr_hells_messenger_death
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

