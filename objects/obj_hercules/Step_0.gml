if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var ap_pos = get_world_position_from_grid(10,3)
	x = ap_pos.x-90
	y = ap_pos.y+30
	image_alpha = 1
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 5000
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
		x -= move_speed
		sprite_index = spr_hercules_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 4
		}
		else{
			image_index = floor(timer/5) mod 4 + 4
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
		sprite_index = spr_hercules_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 20
		}
		else{
			image_index = floor(timer/5) mod 20 + 20
		}
		
		if timer == 1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出9个不同的坐标
			while (array_length(selected_coords) < 9) {
			    // 生成随机坐标
			    var rand_x = irandom_range(0, global.grid_cols - 1);
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
		
		if timer >= 6 * 5 - 1 && timer <= 16 * 5 - 1 && (timer-30) mod 5 == 1 && jump_times < 9{
			var missle = instance_create_depth(x+120,y-90,-800,obj_rumble_missile)
			missle.sprite_index = spr_hercules_missle
			missle.target_col = target_coord[jump_times][0]
			missle.target_row = target_coord[jump_times][1]
			jump_times ++
		}
		
		if timer >= 20 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		sprite_index = spr_hercules_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 5
		}
		else{
			image_index = floor(timer/5) mod 5 + 5
		}
		
		if timer == 18 * 5 + 2{
			var laser1 = instance_create_depth(x-90,y-90,-800,obj_hercules_laser)
			laser1.target_row = grid_row
			laser1.l_type = 0
			laser1.sprite_index = spr_hercules_laser_left
			laser1.move_speed = -8
			var laser2 = instance_create_depth(x+220,y-90,-800,obj_hercules_laser)
			laser2.target_row = grid_row
			laser2.l_type = 0
			laser2.sprite_index = spr_hercules_laser_right
			laser2.move_speed = 8
		}
		
		if timer >= 20 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		sprite_index = spr_hercules_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 5
		}
		else{
			image_index = floor(timer/5) mod 5 + 5
		}
		
		if timer == 18 * 5 + 2{
			var laser1 = instance_create_depth(x+90,y,-800,obj_hercules_laser)
			laser1.target_col = grid_col + 1
			laser1.l_type = 1
			laser1.sprite_index = spr_hercules_laser_down
			laser1.move_speed = 8
			var laser2 = instance_create_depth(x+90,y-110,-800,obj_hercules_laser)
			laser2.target_col = grid_col + 1
			laser2.l_type = 1
			laser2.sprite_index = spr_hercules_laser_up
			laser2.move_speed = -8
		}
		
		if timer >= 20 * 5 - 1{
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
		sprite_index = spr_hercules_death
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