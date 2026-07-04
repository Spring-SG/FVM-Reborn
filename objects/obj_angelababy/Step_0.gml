if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 2500
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	skill_choose = irandom_range(2,2)
	skill_change_style = irandom_range(0,1)
	if skill_choose == 2{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_choose == 0{
		if skill_change_style == 0{
			enemy_row = 0
		}
		else{
			enemy_row = 1
		}
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

switch state{
	case BOSS_STATE.IDLE:
		target_type = "normal"
		sprite_index = spr_angelababy_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 11
		}
		else{
			image_index = floor(timer/5) mod 11 + 11
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.LAUNCH
		}
		break
		
	case BOSS_STATE.APPEAR:
		target_type = "normal"
		sprite_index = spr_angelababy_appear
		
		image_index = floor(timer/5) mod 8
		
		if timer == 8 * 5 - 1{
			timer = 0
			if skill_choose == 0{
				state = BOSS_STATE.SKILL1
			}
			else if skill_choose == 1{
				state = BOSS_STATE.SKILL2
			}
			else if skill_choose == 2{
				state = BOSS_STATE.SKILL3
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL3:
		
		if timer == 1{
			skill_move_type = "move"
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 4) {
			    // 生成随机坐标
			    var rand_x = irandom_range(2, 5);
			    var rand_y = irandom_range(0, global.grid_rows - 1);
			    var new_coord = [rand_x, rand_y];
    
			    // 检查是否已存在
			    var exists = false;
			    for (var i = 0; i < array_length(selected_coords); i++) {
			        if (selected_coords[i][0] == new_coord[0] && selected_coords[i][1] == new_coord[1]) {
			            exists = true;
			            break;
			        }
			    }
    
			    // 如果不存在则添加
			    if (!exists) {
			        array_push(selected_coords, new_coord);
			    }
			}
			target_coord = selected_coords
			
			var selected_coord = target_coord[jump_times]
			var t_pos = get_world_position_from_grid(selected_coord[0],selected_coord[1])
			y_move_speed = (t_pos.y+30-y)/120
			x_move_speed = (t_pos.x-x)/120
			jump_times++
		}
		
		if timer < 14*5-1{
			target_type = "normal"
			sprite_index = spr_angelababy_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 14
			}
			else{
				image_index = floor(timer/5) mod 14 + 14
			}
		}
		else{
			skill_timer++
			if skill_move_type == "move"{
				target_type = "air"
				if x_move_speed <= 0{
					sprite_index = spr_angelababy_move_forward
				}
				else{
					sprite_index = spr_angelababy_move_backward
				}
				if hp > maxhp * hurt_rate{
					image_index = floor(skill_timer/5) mod 11
				}
				else{
					image_index = floor(skill_timer/5) mod 11 + 11
				}
			}
			else{
				target_type = "normal"
				sprite_index = spr_angelababy_skill_3
				if hp > maxhp * hurt_rate{
					image_index = floor(skill_timer/5) mod 24
				}
				else{
					image_index = floor(skill_timer/5) mod 24 + 24
				}
			}
		
			if skill_move_type == "act"{
				if skill_timer == 6 * 5+2{
					var inst = instance_create_depth(x-100,y-15,-800,obj_angelababy_summon)
					inst.grid_row = grid_row
					inst.grid_col = grid_col-1
				}
				if skill_timer >= 24*5-1{
					if jump_times < 5{
						skill_timer = 0	
						if jump_times < 4{
							skill_move_type = "move"
							var selected_coord = target_coord[jump_times]
							var t_pos = get_world_position_from_grid(selected_coord[0],selected_coord[1])
							y_move_speed = (t_pos.y+30-y)/120
							x_move_speed = (t_pos.x-x)/120
						}
						jump_times++
					}
				}
			}
			if skill_move_type == "move"{
				x += x_move_speed
				y += y_move_speed
				if skill_timer >= 120{
					skill_timer = 0
					skill_move_type = "act"
				}
			}
		}
		
		if jump_times >= 5{
			skill_move_type = "act"
			skill_timer = 0
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times = 0
		}
		break
		
	case BOSS_STATE.SKILL1:
		skill_timer++
		
		if skill_move_type == "move"{
			target_type = "air"
			sprite_index = spr_angelababy_idle
			if hp > maxhp * hurt_rate{
				image_index = floor(skill_timer/5) mod 11
			}
			else{
				image_index = floor(skill_timer/5) mod 11 + 11
			}
		}
		else{
			target_type = "normal"
			sprite_index = spr_angelababy_skill_1
			if hp > maxhp * hurt_rate{
				image_index = floor(skill_timer/5) mod 12
			}
			else{
				image_index = floor(skill_timer/5) mod 12 + 12
			}
		}
		
		if skill_move_type == "act"{
			if skill_timer == 6 * 5+2{
				var inst = instance_create_depth(x-250,y-150,-800,obj_angelababy_star)
				inst.grid_row = grid_row
			}
			if skill_timer >= 12*5-1{
				if (skill_change_style == 0 && jump_times < 4) || (skill_change_style == 1 && jump_times < 3){
					skill_timer = 0
					jump_times++
					skill_move_type = "move"
					y_move_speed = (2*global.grid_cell_size_y)/120
				}
			}
		}
		if skill_move_type == "move"{
			y += y_move_speed
			if skill_timer >= 120{
				skill_timer = 0
				skill_move_type = "act"
			}
		}
		
		if (skill_change_style == 0 && jump_times >= 4) || (skill_change_style == 1 && jump_times >= 3){
			skill_move_type = "act"
			skill_timer = 0
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times = 0
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_angelababy_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer == 8 * 5 - 1{
			image_alpha = 0
		}
		if timer == 120{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			skill_choose = irandom_range(0,2)
			skill_change_style = irandom_range(0,1)
			if skill_choose == 2{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 0{
				if skill_change_style == 0{
					enemy_row = 0
				}
				else{
					enemy_row = 1
				}
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	case BOSS_STATE.SKILL2:
		target_type = "normal"
		sprite_index = spr_angelababy_skill_2
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 46
		}
		else{
			image_index = floor(timer/5) mod 46 + 46
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 3) {
			    // 生成随机坐标
			    var rand_x = irandom_range(0, 6);
			    var rand_y = irandom_range(0, global.grid_rows - 1);
			    var new_coord = [rand_x, rand_y];
    
			    // 检查是否已存在
			    var exists = false;
			    for (var i = 0; i < array_length(selected_coords); i++) {
			        if (selected_coords[i][0] == new_coord[0] && selected_coords[i][1] == new_coord[1]) {
			            exists = true;
			            break;
			        }
			    }
    
			    // 如果不存在则添加
			    if (!exists) {
			        array_push(selected_coords, new_coord);
			    }
			}
			target_coord = selected_coords
		}
		
		
		
		if timer == 34 * 5 + 5 * jump_times && jump_times <= 2{
			var coord = target_coord[jump_times]
			var bandage_pos = get_world_position_from_grid(coord[0],coord[1])
			var erase_col = coord[0]
			var erase_row = coord[1]
			var missile = instance_create_depth(bandage_pos.x,bandage_pos.y+15,-800,obj_angelababy_target)
			//missile.target_col = erase_col
			//missile.target_row = erase_row
			jump_times++
		}
		
		if timer == 46 * 5 - 1{
			target_coord = []
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times = 0
		}
	
		break
	case BOSS_STATE.DROP:
		target_type = "air"
		sprite_index = spr_rumble_drop
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 21
		}
		else{
			image_index = floor(timer/5) mod 21 + 21
		}
		if timer == 21 * 5 - 1{
			timer = 0
			if jump_times == 1{
				state = BOSS_STATE.SKILL1
			}
			else{
				state = BOSS_STATE.SKILL2
			}
		}
		break
	case BOSS_STATE.LAUNCH:
		target_type = "air"
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
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_choose == 0{
				if skill_change_style == 0{
					enemy_row = 0
				}
				else{
					enemy_row = 1
				}
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			x_move_speed = (enemy_pos.x-90 - x)/180
			y_move_speed = (enemy_pos.y+30 - y)/180
			timer = 0
			state = BOSS_STATE.MOVE
		}
		break
	case BOSS_STATE.MOVE:
		target_type = "air"
		if x_move_speed <= 0{
			sprite_index = spr_angelababy_move_forward
		}
		else{
			sprite_index = spr_angelababy_move_backward
		}
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 11
		}
		else{
			image_index = floor(timer/5) mod 11 + 11
		}
		x += x_move_speed
		y += y_move_speed
		if timer >= 180{
			timer = 0
			if skill_choose == 0{
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
	
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_angelababy_death
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

