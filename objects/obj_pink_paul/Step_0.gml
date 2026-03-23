if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	skill_choose = irandom_range(1,100)
	var enemy_row = irandom_range(0,global.grid_rows-1)
	var enemy_pos = {}
	if skill_choose <= 50{
		enemy_pos = get_world_position_from_grid(8,enemy_row)
	}
	else{
		enemy_pos = get_world_position_from_grid(irandom_range(2,6),enemy_row)
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
	global.save_data.player.gold += 1000
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
		sprite_index = spr_pink_paul_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer >= wait_time{
			timer = 0
			
			if skill_choose <= 50{
				state = BOSS_STATE.SKILL1
			}
			else{
				state = BOSS_STATE.SKILL2
			}
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_pink_paul_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 14
		}
		else{
			image_index = floor(timer/5) mod 14 + 14
		}
		if timer == 1{
			with obj_card_parent{
				if grid_row == other.grid_row && grid_col == other.grid_col && plant_id != "player" && plant_type != "coffee"{
					instance_destroy()
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
				}
			}
		}
		if timer == 14 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_pink_paul_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 9
		}
		else{
			image_index = floor(timer/5) mod 9 + 9
		}
		
		var target_col = 0
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
		
		if timer mod 90 == 30{
			if ds_list_size(avaliable_pos) > 0{
				var i = irandom_range(0,ds_list_size(avaliable_pos)-1)
				var target_p = ds_list_find_value(avaliable_pos,i)
				var missile = instance_create_depth(x-60,y-180,-800,obj_paul_bullet)
				missile.target_col = target_p.col
				missile.row = target_p.row
				var target_f = get_world_position_from_grid(target_p.col,target_p.row)
				missile.move_speed = (target_f.x - missile.x)/90
				missile.cvspeed = -(target_f.y - missile.y)/90
				ds_list_delete(avaliable_pos,i)
			}
		}
		if timer >= 9*5*8-1{
			ds_list_destroy(avaliable_pos)
			avaliable_pos = ds_list_create()
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_pink_paul_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 13
		}
		else{
			image_index = floor(timer /5) mod 13 + 13
		}
		
		if timer == 8 * 5 - 1{
			with obj_card_parent{
				if abs(grid_col-other.grid_col)+abs(grid_row-other.grid_row) <= 1{
					if plant_id != "player" && plant_type != "coffee" && plant_type != "lilypad"{
						instance_destroy()
						if hp >= max_hp{
							obj_task_manager.card_loss++
						}
					}
				}
			}
		}
		if timer >= 13*5*3{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_pink_paul_disappear
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
			skill_choose = irandom_range(1,100)
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_choose <= 50{
				enemy_pos = get_world_position_from_grid(8,enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(irandom_range(2,6),enemy_row)
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
		sprite_index = spr_pink_paul_death
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

