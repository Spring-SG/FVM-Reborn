if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	image_angle = 0
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	skill_choose = irandom_range(0,0)
	skill_change_style = irandom_range(0,1)
	if skill_choose == 0{
		enemy_row = 0
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 1{
		enemy_row = 0
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 2{
		enemy_row = 3
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	
	move_time = 250
	if skill_choose == 0{
		move_time = 250
		x += 20
	}
	else if skill_choose == 1{
		move_time = 250
		x += 20
	}
	else if skill_choose == 2{
		move_time = 215
	}
	
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
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
		sprite_index = spr_mouse_train_2_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
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
		if timer <= 5 * 9 - 1{
			if train_dir == 0{
				sprite_index = spr_mouse_train_2_head_appear1
			}
			else{
				sprite_index = spr_mouse_train_2_head_appear2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 9
			}
			else{
				image_index = floor(timer/5) mod 9 + 9
			}
		}
		else{
			sprite_index = spr_mouse_train_2_head_idle
			if is_reversed{
				image_xscale = -1.8
			}
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 2
			}
			else{
				image_index = floor(timer/5) mod 2 + 2
			}
		}
		
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		if skill_choose == 0{
			if timer mod 45 == 44 && jump_times < 4{
				if !is_reversed{
					create_train_body_order(1,0,move_time-45*(jump_times+1))
				}
				else{
					create_train_body_pos(1,1,x-210*(jump_times+1),y,move_time-45*(jump_times+1))
				}
				jump_times++
			}
		}
		else if skill_choose == 1{
			if timer mod 45 == 44 && jump_times < 4{
				if skill_2_times == 0{
					create_train_body_order(1,0,move_time-45*(jump_times+1))
				}
				else if skill_2_times == 1{
					create_train_body_pos(1,1,x-210*(jump_times+1),y,move_time-45*(jump_times+1))
				}
				else{
					create_train_body_pos(1,0,x+210*(jump_times+1),y,move_time-45*(jump_times+1))
				}
				jump_times++
			}
		}
		else if skill_choose == 2{
			if timer mod 45 == 44 && jump_times < 3{
				create_train_body_order(1,0,move_time-45*(jump_times+1))
				if jump_times == 1{
					train_body_list[1].skill_3_style = true
				}
				jump_times++
			}
		}
		
		if timer == move_time{
			if skill_choose == 0 && !is_reversed{
				timer = 0
				move_time = 250
				var enemy_pos = get_world_position_from_grid(0,global.grid_rows-1)
				x = enemy_pos.x - 90 + 40
				y = enemy_pos.y + 30
				is_reversed = true
				train_dir = 1
				jump_times = 0
			}
			else if skill_choose == 1 && skill_2_times < 2{
				timer = 0
				move_time = 250
				if skill_2_times == 0{
					var enemy_pos = get_world_position_from_grid(0,global.grid_rows-1)
					x = enemy_pos.x - 90 + 20
					y = enemy_pos.y + 30
					train_dir = 1
					skill_2_times ++
					is_reversed = true
				}
				else if skill_2_times == 1{
					var enemy_pos = get_world_position_from_grid(10,3)
					x = enemy_pos.x - 90 + 20
					y = enemy_pos.y + 30
					train_dir = 0
					skill_2_times ++
					is_reversed = false
					image_xscale = 1.8
				}
				jump_times = 0
			}
			else{
				skill_2_times = 0
				is_reversed = false
				timer = 0
				state = BOSS_STATE.IDLE
				jump_times = 0
			}
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_mouse_train_2_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		if timer == 1{
			with obj_mouse_train_2_body{
				state = BOSS_STATE.SKILL1
				timer = 1
			}
		}
		
		if timer == 46 * 5 + 2{
			for(var i = 0 ; i < 4 ; i++){
				if max(skill_1_damage[i],skill_1_damage[7-i]) < 0.015*maxhp{
					var laser_pos = get_world_position_from_grid(2*i+1,0)
					var laser_inst = instance_create_depth(laser_pos.x,laser_pos.y+90,-800,obj_coke_bomb_explode)
					laser_inst.sprite_index = spr_mouse_train_2_laser
				}
			}
		}
		if timer == 64 * 5 + 2{
			for(var i = 0 ; i < 4 ; i++){
				if max(skill_1_damage[i],skill_1_damage[7-i]) < 0.015*maxhp{
					var laser_pos = get_world_position_from_grid(2*i+1,global.grid_rows-2)
					var laser_inst = instance_create_depth(laser_pos.x,laser_pos.y-40,-801,obj_coke_bomb_explode)
					laser_inst.sprite_index = spr_mouse_train_2_laser_target
					laser_inst.image_yscale = -1.8
				}
			}
		}
		if timer == 65 * 5 + 2{
			for(var i = 0 ; i < 4 ; i++){
				if max(skill_1_damage[i],skill_1_damage[7-i]) < 0.015*maxhp{
					with obj_card_parent{
						if grid_col == (i*2+1) && grid_row != 0 && grid_row != global.grid_rows-1 &&
						plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
							if hp >= max_hp{
								obj_task_manager.card_loss++
							}
							instance_destroy()
						}
					}
				}
			}
		}
		
		if timer >= 80*5 -1{
			skill_1_damage = [0,0,0,0,0,0,0,0]
			move_time = 50
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			disappear_time = 300
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_mouse_train_2_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		
		if timer == 1{
			with obj_mouse_train_2_body{
				state = BOSS_STATE.SKILL2
				timer = 1
			}
		}
		
		if timer == 51 * 5 - 1{
			
			for(var i = 0 ; i < 3 ; i++){
				for(var j = 0 ; j < 5 ; j++){
					if j != 2{
						var mouse_pos1 = get_world_position_from_grid(2+i*2,j+1)
						var inst1 = instance_create_depth(mouse_pos1.x-25,mouse_pos1.y+38,-800,obj_machine_iron_pan_mouse)
						inst1.grid_row = j+1
					}
					
				}
			}
			var mouse_pos1 = get_world_position_from_grid(0,2)
			var inst1 = instance_create_depth(mouse_pos1.x+25,mouse_pos1.y+38,-800,obj_machine_iron_pan_mouse)
			inst1.grid_row = 2
			inst1.move_speed *= -1
			inst1.attack_range *= -1
			inst1.image_xscale = -1.8
			var mouse_pos2 = get_world_position_from_grid(0,4)
			var inst2 = instance_create_depth(mouse_pos2.x+25,mouse_pos2.y+38,-800,obj_machine_iron_pan_mouse)
			inst2.grid_row = 4
			inst2.move_speed *= -1
			inst2.attack_range *= -1
			inst2.image_xscale = -1.8
			
			if !fog_spawn{
				for(var f_row = 0 ; f_row < global.grid_rows ; f_row++){
					for(var j = 1 ; j < global.grid_cols+3;j++){
						var pos = get_world_position_from_grid(j,f_row)
						var fog = instance_create_depth(pos.x+10,pos.y-50,-800,obj_fog)
						fog.col = j
						fog.row = f_row
						fog.image_alpha = 0
					}
				}
				fog_spawn = true
			}
			
		}
		
		if timer >= 63*5 -1{
			move_time = 50
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			disappear_time = 300
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_mouse_train_2_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		
		if timer == 1{
			with train_body_list[1]{
				state = BOSS_STATE.SKILL3
				timer = 1
			}
			with train_body_list[0]{
				state = BOSS_STATE.DISAPPEAR
				move_time = 45+50
				timer = 1
			}
			with train_body_list[2]{
				state = BOSS_STATE.DISAPPEAR
				move_time = 45+50
				train_dir = 1
				timer = 1
			}
		}
		
		if timer >= 10{
			move_time = 50
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			disappear_time = 660
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		if timer <= move_time - 9 * 5{
			sprite_index = spr_mouse_train_2_head_idle
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 2
			}
			else{
				image_index = floor(timer/5) mod 2 + 2
			}
		}
		else{
			image_xscale = 1.8
			if train_dir == 0{
				sprite_index = spr_mouse_train_2_head_disappear1
			}
			else{
				sprite_index = spr_mouse_train_2_head_disappear2
			}
			if hp > maxhp * hurt_rate{
				image_index = floor((timer+5*9-move_time)/5) mod 9
			}
			else{
				image_index = floor((timer+5*9-move_time)/5) mod 9 + 9
			}
		}
		
		if train_dir == 0{
			x -= 4
		}
		else{
			x += 4
		}
		
		if timer == move_time{
			image_alpha = 0
			train_dir = 0
		}
		if timer == move_time+disappear_time{
			clear_train_body()
			image_angle = 0
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
			if skill_choose == 0{
				enemy_row = 0
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 1{
				enemy_row = 0
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 2{
				enemy_row = 3
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			
			move_time = 250
			if skill_choose == 0{
				move_time = 250
				x += 20
			}
			else if skill_choose == 1{
				move_time = 250
				x += 20
			}
			else if skill_choose == 2{
				move_time = 215
			}
			
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_mouse_train_2_head_death
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

var base_depth = -400
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

