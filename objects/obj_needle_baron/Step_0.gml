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
		sprite_index = spr_needle_baron_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer >= wait_time{
			timer = 0
			if skill_count == 0 {
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL2
			}
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
			
			
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_needle_baron_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 14
		}
		else{
			image_index = floor(timer/5) mod 14
		}
		if timer == 14 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		if timer <= 120{
			sprite_index = spr_needle_baron_idle
			image_index = floor(timer /5) mod 8
		
			if hp <= maxhp * hurt_rate{
				image_index += 8
			}
		}
		else{
		
			sprite_index = spr_needle_baron_skill_1
			image_index = floor((timer-120) /5) mod 8
		
			if hp <= maxhp * hurt_rate{
				image_index += 8
			}
		}
		
		if timer == 1{
			ds_list_clear(avaliable_pos)
			for(var i = 0 ; i < global.grid_rows-1;i++){
				for(var j = 2; j < global.grid_cols-1;j++){
					var plant_list = ds_grid_get(global.grid_plants,j,i)
					if ds_list_size(plant_list) > 0{
						ds_list_add(avaliable_pos,{"col":j,"row":i})
					}
				}
			}
			var pos_choose = irandom_range(0,ds_list_size(avaliable_pos)-1)
			var pos_grid = avaliable_pos[| pos_choose]
			t_pos = get_world_position_from_grid(pos_grid.col,pos_grid.row)
			y_move_speed = (t_pos.y+33-y)/120
			x_move = (t_pos.x+80-x)/120
		}
		if timer > 1 && timer <= 120{
			x += x_move
			y += y_move_speed
		}
		if timer == 120{
			var inst = instance_create_depth(x+30,y-95,-800,obj_baron_needle)
		}
		if timer == 230{
			var infected = false
			with obj_card_parent{
				if grid_col == other.t_pos.col && grid_row == other.t_pos.row && plant_type != "coffee" && !invincible{
					other.hp = clamp(other.hp+other.maxhp*0.035,0,other.maxhp)
					var inst = instance_create_depth(other.x,other.y,-800,obj_card_heal_effect)
					inst.sprite_index = spr_mouse_heal_effect
					if plant_id != "player"{
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
						instance_destroy()
					}
					else{
						hp = 10
						event_user(2)
					}
					infected = true
				}
			}
			if infected{
				instance_create_depth(t_pos.x,t_pos.y+33,-800,obj_mummy_mouse)
			}
			else{
				hp = clamp(hp+maxhp*0.035,0,maxhp)
			}
		}
		
		if timer >= 246 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
	
		if timer <= 5 * 5 - 1{
			sprite_index = spr_needle_baron_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 5
			}
			else{
				image_index = floor(timer /5) mod 5 + 5
			}
		}
		else if timer <= 145{
			sprite_index = spr_needle_baron_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = 4
			}
			else{
				image_index = 9
			}
		}
		else{
			sprite_index = spr_needle_baron_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer - 145)/5) mod 3
			}
			else{
				image_index = floor((timer - 145)/5) mod 3 + 3
			}
		}
		
		if timer == 85{
			for(var i = 0;i < 3 ; i++){
				var tg_row = irandom_range(0,global.grid_rows-1)
				var tg_pos = get_world_position_from_grid(irandom_range(0,6),tg_row)
				var inst = instance_create_depth(x-60+10*i,y-75,-800,obj_baron_bats)
				inst.y_speed = (tg_pos.y+33-inst.y)/120
				inst.x_speed = (tg_pos.x-inst.x)/120
			}
		}
		
		if timer >= 159{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	case BOSS_STATE.SKILL2:
		if timer <= 120{
			sprite_index = spr_needle_baron_idle
			image_index = floor(timer /5) mod 8
		
			if hp <= maxhp * hurt_rate{
				image_index += 8
			}
		}
		else{
		
			sprite_index = spr_needle_baron_skill_2
			image_index = floor((timer-120) /5) mod 10
		
			if hp <= maxhp * hurt_rate{
				image_index += 10
			}
		}
		
		if timer == 1{
			t_type = irandom_range(0,1)
			if t_type == 0{
				t_pos = get_world_position_from_grid(10,0)
			}
			else{
				t_pos = get_world_position_from_grid(10,global.grid_rows-1)
			}
			y_move_speed = (t_pos.y+33-y)/120
			x_move = (t_pos.x-80-x)/120
		}
		if timer > 1 && timer <= 120{
			x += x_move
			y += y_move_speed
		}
		
		if timer == 120 + 9 * 5 - 2{
			var inst = instance_create_depth(x-90,y-20,-800,obj_baron_blade)
			if t_type == 0{
				inst.image_yscale = -1.8
				inst.y -= 80
			}
			inst.type = t_type
		}
		
		if timer >= 120 + 10*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_needle_baron_appear
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
		sprite_index = spr_needle_baron_death
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

