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
		enemy_pos = get_world_position_from_grid(9,enemy_row)
		image_xscale = 1.8
	}
	else if skill_count == 0{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else{
		enemy_pos = get_world_position_from_grid(1,enemy_row)
		image_xscale = -1.8
	}
	x = enemy_pos.x - 90
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
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
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
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
			
			
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_witch_shaman_mouse_appear1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 6
		}
		else{
			image_index = floor(timer/5) mod 6 + 6
		}
		if timer == 6 * 5 - 1{
			timer = 0
			state = BOSS_STATE.IDLE
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_witch_shaman_mouse_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 22
		}
		else{
			image_index = floor(timer/5) mod 22 + 22
		}
		
		if timer == 18 * 5 + 2{
			var sheep_pos = get_world_position_from_grid(0,grid_row)
			var sheep_x = sheep_pos.x-50
			var sheep_y = sheep_pos.y + 5
			instance_create_depth(sheep_x,sheep_y,-800,obj_witch_shaman_sheep)
		}
		
		if timer >= 22*5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL2:
	
		sprite_index = spr_witch_shaman_mouse_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 24
		}
		else{
			image_index = floor(timer/5) mod 24 + 24
		}
		
		if timer == 20 * 5 + 2{
			var t_row = irandom_range(1,global.grid_rows-2)
			var t_col = irandom_range(3,6)
			with obj_card_parent{
				if abs(grid_col - t_col) <= 1 && abs(grid_row - t_row) <= 1 &&
				plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
					if hp >= max_hp{
						obj_task_manager.card_loss++
					}
					instance_destroy()
					var effect_inst = instance_create_depth(x,y+15,depth,obj_coke_bomb_explode)
					effect_inst.sprite_index = spr_witch_shaman_blood_effect
				}
			}
		}
		
		
		if timer >= 24*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_witch_shaman_mouse_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
		}
		
		if timer == 10 * 5 - 1{
			with obj_enemy_parent{
				if hp > 0{
					if maxhp < 600{
						maxhp = 600
					}
					if hp <= maxhp - 600{
						hp += 600
					}
					else{
						hp = maxhp
					}
					var inst = instance_create_depth(x,y-45,depth-1,obj_card_heal_effect)
					inst.sprite_index = spr_mouse_heal_effect
				}
				if move_speed > 0 && !is_boss{
					move_speed += 2
					array_push(other.speedup_enemy_list,id)
				}
			}
		}
		if timer == 59 * 5 - 1{
			with obj_enemy_parent{
				if array_get_index(other.speedup_enemy_list,id) != -1{
					move_speed -= 2
				}
			}
		}
		
		if timer >= 60*5-1{
			speedup_enemy_list = []
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_witch_shaman_mouse_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 8
		}
		else{
			image_index = floor(timer/5) mod 8 + 8
		}
		if timer == 8 * 5 - 1{
			image_alpha = 0
		}
		if timer == 180{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 2{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
				image_xscale = 1.8
			}
			else if skill_count == 0{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(1,enemy_row)
				image_xscale = -1.8
			}
			x = enemy_pos.x - 90
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_witch_shaman_mouse_death
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

