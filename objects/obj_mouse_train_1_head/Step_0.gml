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
	skill_choose = irandom_range(0,1)
	skill_change_style = irandom_range(0,1)
	if skill_choose == 0{
		enemy_row = 9
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 1{
		if skill_change_style == 0{
			image_angle = 180
			enemy_pos = get_world_position_from_grid(5,-3)
		}
		else{
			enemy_pos = get_world_position_from_grid(7,9)
		}
		
	}
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	
	move_time = 250
	if skill_choose == 0{
		if skill_change_style == 0{
			y -= (global.grid_cell_size_y - 15)
		}
		else{
			y -= (global.grid_cell_size_y * 2 - 15)
		}
		create_train_body(4,0)
	}
	else if skill_choose == 1{
		if skill_change_style == 0{
			y += (global.grid_cell_size_y * 0.5 + 15)
			create_train_body(4,1)
		}
		else{
			move_time = 250 +round(2*global.grid_cell_size_y/4)
			y -= (global.grid_cell_size_y - 15)
			create_train_body(4,0)
		}
		
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
		sprite_index = spr_mouse_train_1_head_idle
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
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_mouse_train_1_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		
		if (skill_choose == 1 && skill_change_style == 0)||(skill_choose == 1 && skill_change_style == 1 && is_reversed){
			y += 4
		}
		else{
			y -= 4
		}
		
		if timer == move_time{
			if skill_choose == 1 && skill_change_style == 1 && !is_reversed{
				timer = 0
				move_time = 250
				image_angle = 180
				var enemy_pos = get_world_position_from_grid(2,-3)
				x = enemy_pos.x - 90
				y = enemy_pos.y + 30
				y += (global.grid_cell_size_y * 0.5 + 15)
				for(var i = 0 ; i < array_length(train_body_list) ; i++){
					train_body_list[i].wait_time += 250
				}
				create_train_body(4,1)
				for(var i = 4 ; i < array_length(train_body_list) ; i++){
					train_body_list[i].is_reversed = true
				}
				is_reversed = true
			}
			else{
				is_reversed = false
				timer = 0
				state = BOSS_STATE.IDLE
			}
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_mouse_train_1_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		
		if timer == 26 * 5 + 2{
			if skill_change_style == 0{
				for(var i = 0 ; i < 3 ; i++){
					jump_times = 1 + 2 * i
					var bullet_pos = get_world_position_from_grid(8,jump_times)
					var inst = instance_create_depth(bullet_pos.x-80,bullet_pos.y-35,-800,obj_mouse_train_1_bullet)
					inst.grid_row = jump_times
				}
			}
			else{
				for(var i = 0 ; i < 4 ; i++){
					jump_times = 0 + 2 * i
					var bullet_pos = get_world_position_from_grid(8,jump_times)
					var inst = instance_create_depth(bullet_pos.x-80,bullet_pos.y-35,-800,obj_mouse_train_1_bullet)
					inst.grid_row = jump_times
				}
			}
		}
		
		if timer >= 42*5 -1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
	
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_mouse_train_1_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		
		if timer == 15 * 5 + 2{
			if skill_change_style == 0{
				for(var i = 0 ; i < 4 ; i++){
					jump_times = 0 + 2 * i
					var mouse_pos1 = get_world_position_from_grid(3,jump_times)
					var mouse_pos2 = get_world_position_from_grid(5,jump_times)
					var inst1 = instance_create_depth(mouse_pos1.x+25,mouse_pos1.y+33,-800,obj_machine_iron_pan_mouse)
					inst1.grid_row = jump_times
					var inst2 = instance_create_depth(mouse_pos2.x-25,mouse_pos2.y+33,-800,obj_machine_iron_pan_mouse)
					inst2.move_speed *= -1
					inst2.attack_range *= -1
					inst2.image_xscale = -1.8
				}
			}
			else{
				for(var i = 0 ; i < 4 ; i++){
					jump_times = 0 + 2 * i
					var mouse_pos1 = get_world_position_from_grid(2,jump_times)
					var inst1 = instance_create_depth(mouse_pos1.x-25,mouse_pos1.y+33,-800,obj_machine_iron_pan_mouse)
					inst1.grid_row = jump_times
					inst1.move_speed *= -1
					inst1.attack_range *= -1
					inst1.image_xscale = -1.8
				}
				for(var i = 0 ; i < 3 ; i++){
					jump_times = 1 + 2 * i
					var mouse_pos1 = get_world_position_from_grid(5,jump_times)
					var inst1 = instance_create_depth(mouse_pos1.x+25,mouse_pos1.y+33,-800,obj_machine_iron_pan_mouse)
					inst1.grid_row = jump_times
				}
			}
		}
		
		if timer >= 27*5 -1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_mouse_train_1_head_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 2
		}
		else{
			image_index = floor(timer/5) mod 2 + 2
		}
		
		if (skill_choose == 1 && skill_change_style == 0) || (skill_choose == 1 && skill_change_style == 1){
			y += 4
		}
		else{
			y -= 4
		}
		
		if timer == 250{
			image_alpha = 0
		}
		if timer == 430{
			clear_train_body()
			image_angle = 0
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			skill_change_style = irandom_range(0,1)
			for(var i = 0 ; i < 100 ; i++){
				var current_choose = irandom_range(0,1)
				if current_choose != skill_choose{
					skill_choose = current_choose
					break
				}
			}
			if skill_choose == 0{
				enemy_row = 9
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 1{
				if skill_change_style == 0{
					image_angle = 180
					enemy_pos = get_world_position_from_grid(5,-3)
				}
				else{
					enemy_pos = get_world_position_from_grid(7,9)
				}
		
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			
			move_time = 250
			if skill_choose == 0{
				if skill_change_style == 0{
					y -= (global.grid_cell_size_y - 15)
				}
				else{
					y -= (global.grid_cell_size_y * 2 - 15)
				}
				create_train_body(4,0)
			}
			else if skill_choose == 1{
				if skill_change_style == 0{
					y += (global.grid_cell_size_y * 0.5 + 15)
					create_train_body(4,1)
				}
				else{
					move_time = 250 +round(2*global.grid_cell_size_y/4)
					y -= (global.grid_cell_size_y - 15)
					create_train_body(4,0)
				}
		
			}
			
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_mouse_train_1_head_death
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

