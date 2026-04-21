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
		enemy_pos = get_world_position_from_grid(6,enemy_row)
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
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 4000
	image_alpha = 1
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
		sprite_index = spr_hot_vajra_idle
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
		sprite_index = spr_hot_vajra_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if timer == 6*5-1{
			with obj_card_parent{
				if grid_row == other.grid_row && grid_col == other.grid_col && plant_id != "player" && plant_type != "coffee" && plant_id != "cotton_candy"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		if timer == 12 * 5 - 1{
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
		sprite_index = spr_hot_vajra_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 14
		}
		else{
			image_index = floor(timer/5) mod 14 + 14
		}
		
		
		if timer == 6*5{
			with obj_card_parent{
				if grid_col >= other.grid_col - 2 && grid_col <= other.grid_col && abs(grid_row-other.grid_row) <= 1 && plant_id != "player" && plant_type != "coffee" && plant_id != "cotton_candy"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		if timer >= 14*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL3:
		if timer <= 12*5 - 1{
		
			sprite_index = spr_hot_vajra_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 12
			}
			else{
				image_index = floor(timer /5) mod 12 + 12
			}
		}
		else if timer >= 12*5 +60*8{
		
			sprite_index = spr_hot_vajra_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = 12 - floor((timer-(12*5 +60*8)) /5) mod 12
			}
			else{
				image_index =(12 - floor((timer-(12*5 +60*8)) /5) mod 12) + 12
			}
		}
		else{
			sprite_index = spr_hot_vajra_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 10
			}
			else{
				image_index = floor(timer /5) mod 10 + 10
			}
		}
		
		if timer == 5 * 5 - 1{
			spike_count = irandom_range(0,1)
			if spike_count mod 2 == 0{
				var spike_pos1 = get_world_position_from_grid(0,0)
				spike_left_1 = instance_create_depth(spike_pos1.x,spike_pos1.y+25,-800,obj_vajra_spike)
				spike_left_1.maxhp *= (1+((maxhp - 80000)/80000)*0.5)
				spike_left_1.hp = spike_left_1.maxhp
			
				var spike_pos2 = get_world_position_from_grid(0,global.grid_rows-1)
				spike_left_2 = instance_create_depth(spike_pos2.x,spike_pos2.y+25,-800,obj_vajra_spike)
				spike_left_2.maxhp *= (1+((maxhp - 80000)/80000)*0.5)
				spike_left_2.hp = spike_left_2.maxhp
			
				var spike_pos3 = get_world_position_from_grid(global.grid_cols-1,0)
				spike_right_1 = instance_create_depth(spike_pos3.x,spike_pos3.y+25,-800,obj_vajra_spike)
				spike_right_1.maxhp *= (1+((maxhp - 80000)/80000)*0.5)
				spike_right_1.hp = spike_right_1.maxhp
			
				var spike_pos4 = get_world_position_from_grid(global.grid_cols-1,global.grid_rows-1)
				spike_right_2 = instance_create_depth(spike_pos4.x,spike_pos4.y+25,-800,obj_vajra_spike)
				spike_right_2.maxhp *= (1+((maxhp - 80000)/80000)*0.5)
				spike_right_2.hp = spike_right_2.maxhp
			}
			else{
				var spike_pos1 = get_world_position_from_grid(4,0)
				spike_left_1 = instance_create_depth(spike_pos1.x,spike_pos1.y+25,-800,obj_vajra_spike)
				spike_left_1.maxhp *= (1+((maxhp - 80000)/80000)*0.5)
				spike_left_1.hp = spike_left_1.maxhp
			
				var spike_pos2 = get_world_position_from_grid(0,3)
				spike_left_2 = instance_create_depth(spike_pos2.x,spike_pos2.y+25,-800,obj_vajra_spike)
				spike_left_2.maxhp *= (1+((maxhp - 80000)/80000)*0.5)
				spike_left_2.hp = spike_left_2.maxhp
			
				var spike_pos3 = get_world_position_from_grid(global.grid_cols-1,3)
				spike_right_1 = instance_create_depth(spike_pos3.x,spike_pos3.y+25,-800,obj_vajra_spike)
				spike_right_1.maxhp *= (1+((maxhp - 80000)/80000)*0.5)
				spike_right_1.hp = spike_right_1.maxhp
			
				var spike_pos4 = get_world_position_from_grid(4,global.grid_rows-1)
				spike_right_2 = instance_create_depth(spike_pos4.x,spike_pos4.y+25,-800,obj_vajra_spike)
				spike_right_2.maxhp *= (1+((maxhp - 80000)/80000)*0.5)
				spike_right_2.hp = spike_right_2.maxhp
			}
			
		}
		if timer == 60 + 60* 8 - 1{
			if spike_count mod 2 == 0{
				var spike_pos_list = [
					[1,0,0,0,0,0,0,0,1],
					[0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0],
					[1,0,0,0,0,0,0,0,1]
				]
				if !instance_exists(spike_left_1){
					spike_pos_list[0][0] = 0
				}
				if !instance_exists(spike_left_2){
					spike_pos_list[6][0] = 0
				}
				if !instance_exists(spike_right_1){
					spike_pos_list[0][8] = 0
				}
				if !instance_exists(spike_right_2){
					spike_pos_list[6][8] = 0
				}
				var clear_list = connectOnesToTwos(spike_pos_list)
				for(var i = 0;i<7;i++){
					for(var j = 0 ; j < 9 ; j++){
						if clear_list[i][j] != 0{
							with obj_card_parent{
								if grid_row == i && grid_col == j && !invincible
								&& plant_type != "coffee" && plant_id != "player" && plant_id != "cotton_candy"{
									if hp >= max_hp{
										obj_task_manager.card_loss++
									}
									instance_destroy()
								}
							}
						}
					}
				}
				if instance_exists(spike_left_1) && instance_exists(spike_right_1){
					var light_pos = get_world_position_from_grid(4,0)
					instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
				}
				if instance_exists(spike_left_2) && instance_exists(spike_right_2){
					var light_pos = get_world_position_from_grid(4,global.grid_rows-1)
					instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
				}
				if instance_exists(spike_left_1) && instance_exists(spike_left_2){
					var light_pos = get_world_position_from_grid(0,3)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_horizontal
				}
				if instance_exists(spike_right_1) && instance_exists(spike_right_2){
					var light_pos = get_world_position_from_grid(global.grid_cols-1,3)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_horizontal
				}
				if instance_exists(spike_left_1) && instance_exists(spike_right_2){
					var light_pos = get_world_position_from_grid(4,3)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_incline_1
				}
				if instance_exists(spike_left_2) && instance_exists(spike_right_1){
					var light_pos = get_world_position_from_grid(4,3)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_incline_2
				}
			}
			else{
				var spike_pos_list = [
					[0,0,0,0,1,0,0,0,0],
					[0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0],
					[1,0,0,0,0,0,0,0,1],
					[0,0,0,0,0,0,0,0,0],
					[0,0,0,0,0,0,0,0,0],
					[0,0,0,0,1,0,0,0,0]
				]
				if !instance_exists(spike_left_1){
					spike_pos_list[0][4] = 0
				}
				if !instance_exists(spike_left_2){
					spike_pos_list[3][0] = 0
				}
				if !instance_exists(spike_right_1){
					spike_pos_list[3][8] = 0
				}
				if !instance_exists(spike_right_2){
					spike_pos_list[6][4] = 0
				}
				var clear_list = connectOnesToTwos(spike_pos_list)
				for(var i = 0;i<7;i++){
					for(var j = 0 ; j < 9 ; j++){
						if clear_list[i][j] != 0{
							with obj_card_parent{
								if grid_row == i && grid_col == j && !invincible
								&& plant_type != "coffee" && plant_id != "player" && plant_id != "cotton_candy"{
									if hp >= max_hp{
										obj_task_manager.card_loss++
									}
									instance_destroy()
								}
							}
						}
					}
				}
				if instance_exists(spike_left_1) && instance_exists(spike_right_1){
					var light_pos = get_world_position_from_grid(6,1.5)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_incline_1_short
				}
				if instance_exists(spike_left_2) && instance_exists(spike_right_2){
					var light_pos = get_world_position_from_grid(2,4.5)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_incline_1_short
				}
				if instance_exists(spike_left_1) && instance_exists(spike_left_2){
					var light_pos = get_world_position_from_grid(2,1.5)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_incline_2_short
				}
				if instance_exists(spike_right_1) && instance_exists(spike_right_2){
					var light_pos = get_world_position_from_grid(6,4.5)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_incline_2_short
				}
				if instance_exists(spike_left_1) && instance_exists(spike_right_1){
					var light_pos = get_world_position_from_grid(4,3)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_horizontal
				}
				if instance_exists(spike_left_2) && instance_exists(spike_right_2){
					var light_pos = get_world_position_from_grid(4,3)
					var light_inst = instance_create_depth(light_pos.x,light_pos.y-50,-800,obj_vajra_lightning)
					light_inst.sprite_index = spr_vajra_lightning_vertical
				}
			}
			
		}
		if timer >= 120 + 60 * 8 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL4:
		var skill_time = 50 * 60
		
		if timer <= 26 * 5 - 1{
			sprite_index = spr_hot_vajra_skill_4
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 26
			}
			else{
				image_index = floor(timer /5) mod 26 + 26
			}
		}
		else if timer <= 26 * 5 + skill_time-1{
			image_alpha = 0
		}
		else{
			image_alpha = 1
			sprite_index = spr_hot_vajra_skill_4_return
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-130-skill_time)/5) mod 45
			}
			else{
				image_index = floor((timer-130-skill_time) /5) mod 45 + 45
			}
		}
		if timer == 26* 5 + 1{
			y -= room_width
			obj_battle.boss_count -= 1
			band_inst1 = instance_create_depth(x,y,-800,obj_pete)
			obj_battle.boss_count += 1
			band_inst2 = instance_create_depth(x,y,-800,obj_fog_julie)
			obj_battle.boss_count += 1
			band_inst1.maxhp = maxhp/2
			band_inst2.maxhp = maxhp/2
			band_inst1.hp = hp/2
			band_inst2.hp = hp/2
			obj_battle.boss_count += 1
			instance_destroy(hpbar_inst)
		}
		if timer > 26 * 5 + 1 && timer < 26 * 5 + skill_time+1{
			if !instance_exists(band_inst1) && !instance_exists(band_inst2){
				instance_destroy()
			}
		}
		if timer == 26 * 5 + skill_time+1{
			if instance_exists(band_inst1) && instance_exists(band_inst2){
				y += room_width
				hp = band_inst1.hp + band_inst2.hp
				instance_destroy(band_inst1)
				instance_destroy(band_inst2)
				hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
				hpbar_inst.target_boss = id
				hpbar_inst.boss_id = mouse_id
				if obj_battle.boss_count > 1{
					hpbar_inst.y -= 40
				}
			}
			else{
				instance_destroy()
			}
		}
		
		if timer >= 71*5 + skill_time -1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_hot_vajra_skill_2
		
		image_index = floor(timer /5) mod 9
		
		
		if hp <= maxhp * hurt_rate{
			image_index += 9
		}
		
		if timer == 6 * 5 - 1{
			for(var i = 0 ; i < 5 ; i ++){
				var inst = instance_create_depth(x+275,y-50,-800,obj_vajra_lava)
				inst.target_col = irandom_range(0,8)
				inst.target_row = irandom_range(0,global.grid_rows-1)
			}
		}
		
		if timer >= 9*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_hot_vajra_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if timer == 12 * 5 - 1{
			image_alpha = 0
		}
		if timer == 240{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 2{
				enemy_pos = get_world_position_from_grid(6,enemy_row)
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
		sprite_index = spr_pete_death
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

