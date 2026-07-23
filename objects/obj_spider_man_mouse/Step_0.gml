if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	skill_choose = irandom_range(0,2)
	if skill_choose == 2{
		enemy_row = 3
		enemy_pos = get_world_position_from_grid(5,enemy_row)
	}
	else if skill_choose == 0{
		enemy_row = 3
		enemy_pos = get_world_position_from_grid(5,enemy_row)  
	}
	else{
		enemy_row = 3
		enemy_pos = get_world_position_from_grid(5,enemy_row)
	}
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	y -= 1110
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 3000
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
		sprite_index = spr_spider_man_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
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
		sprite_index = spr_spider_man_mouse_idle
		y += 15
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if timer == 15 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_spider_man_mouse_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 50
		}
		else{
			image_index = floor(timer/5) mod 50 + 50
		}
		
		if timer mod 125 == 65{
			var summon_row = irandom_range(3,global.grid_rows-1)
			var summon_col = irandom_range(1,5)
			var summon_pos = get_world_position_from_grid(summon_col,summon_row)
			instance_create_depth(summon_pos.x+10,summon_pos.y+38,-800,obj_mirror_mouse)
			var effect_inst = instance_create_depth(summon_pos.x+10,summon_pos.y-30,-800,obj_coke_bomb_explode)
			effect_inst.sprite_index = spr_spider_man_mouse_effect
		}
		
		if timer >= 150 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL2:
		skill_timer++
		if skill_timer <= 75{
			sprite_index = spr_spider_man_mouse_skill_2
			if hp > maxhp * hurt_rate{
				image_index = 0
			}
			else{
				image_index = 1
			}
			y -= 15
		}
		else if skill_timer <= 150{
			sprite_index = spr_spider_man_mouse_idle
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-75)/5) mod 10
			}
			else{
				image_index = floor((skill_timer-75)/5) mod 10 + 10
			}
			y += 15
		}
		else{
			sprite_index = spr_spider_man_mouse_skill_2_ready
			if hp > maxhp * hurt_rate{
				image_index = floor((skill_timer-150)/5) mod 3
			}
			else{
				image_index = floor((skill_timer-150)/5) mod 3 + 3
			}
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 3) {
			    // 生成随机坐标
			    var rand_x = irandom_range(3, 5);
			    var rand_y = irandom_range(2, 4);
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
		
		if timer mod 165 == 90 && jump_times < 3{
			var target_inst_pos = target_coord[jump_times]
			var inst_pos = get_world_position_from_grid(target_inst_pos[0],target_inst_pos[1])
			var iron_target_inst = instance_create_depth(inst_pos.x,inst_pos.y+15,-800,obj_coke_bomb_explode)
			iron_target_inst.sprite_index = spr_angelababy_target
			
		}
		if timer mod 165 == 75 && jump_times < 3{
			var target_inst_pos = target_coord[jump_times]
			var inst_pos = get_world_position_from_grid(target_inst_pos[0],target_inst_pos[1])
			x = inst_pos.x
			y = inst_pos.y - 1125
		}
		if timer mod 165 == 164 && jump_times < 3{
			var erase_col = target_coord[jump_times][0]
			var erase_row = target_coord[jump_times][1]
			with obj_card_parent{
				if grid_col == erase_col && grid_row == erase_row &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					var effect_inst = instance_create_depth(x,y,-800,obj_card_stolen)
					effect_inst.sprite_index = sprite_index
					effect_inst.image_index = image_index
					instance_destroy()
				}
			}
			skill_timer = 0
			jump_times ++
		}
		
		if timer == 165 * 3 - 1{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			jump_times = 0
			target_coord = []
		}
		break
		
	case BOSS_STATE.SKILL3:
		sprite_index = spr_spider_man_mouse_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 24
		}
		else{
			image_index = floor(timer/5) mod 24 + 24
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 2) {
			    // 生成随机坐标
			    var rand_x = irandom_range(1, 7);
			    var rand_y = irandom_range(1, global.grid_rows - 2);
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
		
		if timer mod 120 == 30 && jump_times < 2{
			var target_inst_pos = target_coord[jump_times]
			var inst_pos = get_world_position_from_grid(target_inst_pos[0],target_inst_pos[1])
			var iron_target_inst = instance_create_depth(inst_pos.x+55,inst_pos.y-35,-800,obj_coke_bomb_explode)
			iron_target_inst.sprite_index = spr_angelababy_target
			
		}
		
		if timer mod 120 == 60 && jump_times < 2{
			var missile = instance_create_depth(x-35,y-260,-800,obj_spider_man_mouse_web)
			missile.target_col = target_coord[jump_times][0]
			missile.target_row = target_coord[jump_times][1]
			var target_f = get_world_position_from_grid(target_coord[jump_times][0],target_coord[jump_times][1])
			missile.move_speed = (target_f.x - missile.x)/30
			missile.cvspeed = -(target_f.y - missile.y)/30
			missile.image_angle = point_direction(missile.x,missile.y,target_f.x,target_f.y)
			
			jump_times++
			
		}
		
		if timer >= 2*24*5-1{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
			jump_times = 0
			target_coord = []
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_spider_man_mouse_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		if y > 0{
			y -= 15
		}
		if timer == 15 * 5 - 1{
			image_alpha = 0
		}
		if timer == 180{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			for(var i = 0 ; i < 100 ; i++){
				var current_choose = irandom_range(0,2)
				if current_choose != skill_choose{
					skill_choose = current_choose
					break
				}
			}
			if skill_choose == 2{
				enemy_row = 3
				enemy_pos = get_world_position_from_grid(5,enemy_row)
			}
			else if skill_choose == 0{
				enemy_row = 3
				enemy_pos = get_world_position_from_grid(5,enemy_row) 
			}
			else{
				enemy_row = 3
				enemy_pos = get_world_position_from_grid(5,enemy_row)
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			y -= 1110
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_spider_man_mouse_death
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

var base_depth = -10 - (zombie_grid.row * 45) - 45
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

