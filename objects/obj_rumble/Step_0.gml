if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 750
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
}

switch state{
	case BOSS_STATE.IDLE:
		target_type = "normal"
		sprite_index = spr_rumble_idle
		if hp > maxhp * hurt_rate{
			image_index = 0
		}
		else{
			image_index = 1
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.LAUNCH
			wait_time = 180
		}
		break
		
	case BOSS_STATE.APPEAR:
		target_type = "normal"
		sprite_index = spr_rumble_appear
		
		image_index = floor(timer/5) mod 11
		
		if timer == 11 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL2:
		target_type = "normal"
		sprite_index = spr_rumble_skill_2
		if timer < 480{
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 16
			}
			else{
				image_index = floor(timer/5) mod 16 + 17
			}
		}
		else{
			if hp > maxhp * hurt_rate{
				image_index = 16
			}
			else{
				image_index = 33
			}
		}
		
		if timer == 480{
			instance_create_depth(x-150,y-120,-800,obj_rumble_laser)
			with obj_card_parent{
				if grid_row == other.grid_row &&plant_id != "player" && plant_type !="lilypad"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			}
			
		}
		if timer == 510{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL1:
		target_type = "normal"
		sprite_index = spr_rumble_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 16
		}
		else{
			image_index = floor(timer/5) mod 15 + 16
		}
		
		if timer == 19{
			for(var i = 0 ; i < global.grid_rows-1;i++){
				for(var j = 0 ; j < global.grid_cols-1;j++){
					var plant_list = ds_grid_get(global.grid_plants,j,i)
					if ds_list_size(plant_list) > 0{
						ds_list_add(avaliable_pos,{"col":j,"row":i})
					}
				}
			}
		}
		
		if timer == 4*5 /*|| timer == 9 *5 || timer == 14*5*/{
			if ds_list_size(avaliable_pos) > 0{
				var i = irandom_range(0,ds_list_size(avaliable_pos)-1)
				var target_p = ds_list_find_value(avaliable_pos,i)
				var missile = instance_create_depth(x-60,y-180,-800,obj_rumble_missile)
				missile.target_col = target_p.col
				missile.target_row = target_p.row
				ds_list_delete(avaliable_pos,i)
			}
		}
		if timer == 16 * 5 - 1{
			ds_list_destroy(avaliable_pos)
			avaliable_pos = ds_list_create()
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times += 1
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_rumble_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 9
		}
		else{
			image_index = floor(timer/5) mod 9 + 9
		}
		if timer == 9 * 5 - 1{
			image_alpha = 0
		}
		if timer == 210{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = get_world_position_from_grid(10,enemy_row)
			x = enemy_pos.x - 50
			y = enemy_pos.y + 30
			image_alpha = 1
			var shape_i = irandom_range(1,100)
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	case BOSS_STATE.SKILL3:
		target_type = "normal"
		sprite_index = spr_rumble_skill_3
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 24
		}
		else{
			image_index = floor(timer/5) mod 24 + 24
		}
		if timer == 14 * 5{
			with obj_card_parent{
				
				if grid_row <= other.target_pos.row && grid_row >= other.target_pos.row-1
				&& grid_col <= other.target_pos.col && grid_col >= other.target_pos.col-1
				&& !invincible &&plant_id != "player"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
				}
			
			}
		}
		if timer >= 24*5-1{
			timer = 0
			state = BOSS_STATE.IDLE
			jump_times += 1
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
		sprite_index = spr_rumble_launch
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 27
		}
		else{
			image_index = floor(timer/5) mod 27 + 27
		}
		if timer == 27 * 5 - 1{
			if jump_times == 0 || jump_times == 2{
				target_pos.row = irandom_range(1,global.grid_rows-1)
				target_pos.col = irandom_range(3,6)
				var land_pos = get_world_position_from_grid(target_pos.col,target_pos.row)
				x_move_speed = (land_pos.x-10 - x)/180
				y_move_speed = (land_pos.y+33 - y)/180
				timer = 0
				state = BOSS_STATE.MOVE
			}
			else{
				target_pos.row = irandom_range(1,global.grid_rows-1)
				target_pos.col = 10
				var land_pos = get_world_position_from_grid(target_pos.col,target_pos.row)
				x_move_speed = (land_pos.x-80 - x)/180
				y_move_speed = (land_pos.y+33 - y)/180
				timer = 0
				state = BOSS_STATE.MOVE
			}
		}
		break
	case BOSS_STATE.MOVE:
		target_type = "air"
		if x_move_speed <= 0{
			sprite_index = spr_rumble_move_forward
		}
		else{
			sprite_index = spr_rumble_move_backword
		}
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		x += x_move_speed
		y += y_move_speed
		if timer >= 180{
			timer = 0
			if jump_times == 0 || jump_times == 2{
				state = BOSS_STATE.SKILL3
			}
			else{
				state = BOSS_STATE.DROP
			}
		}
		
		break
	
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_rumble_death
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

