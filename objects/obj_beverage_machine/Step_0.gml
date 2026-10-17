if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = 3
	var enemy_pos = {}
	if skill_count == 2{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_count == 0{
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
		sprite_index = spr_beverage_machine_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 10
		}
		else{
			image_index = floor(timer/5) mod 10 + 10
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
		sprite_index = spr_beverage_machine_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 46
		}
		else{
			image_index = floor(timer/5) mod 46
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
		if timer == 46 * 5 - 1{
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
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_beverage_machine_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 41
		}
		else{
			image_index = floor(timer/5) mod 41 + 41
		}
		
		if timer == 32*5-1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 4) {
			    // 生成随机坐标
			    var rand_x = irandom_range(2, 6);
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
			var target_coord = selected_coords
			for(var i = 0 ; i < array_length(target_coord);i++){
				var coord = target_coord[i]
				var bandage_pos = get_world_position_from_grid(coord[0],coord[1])
				var claw_inst = instance_create_depth(bandage_pos.x+10,bandage_pos.y+40,-800,obj_beverage_skill_1_bullet)
			}
		}
		
		if timer >= 41*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL2:
		
		sprite_index = spr_beverage_machine_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer /5) mod 41
		}
		else{
			image_index = floor(timer /5) mod 41 + 41
		}
		
		if timer == 32*5-1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 2) {
			    // 生成随机坐标
			    var rand_x = irandom_range(2, 6);
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
			var target_coord = selected_coords
			for(var i = 0 ; i < array_length(target_coord);i++){
				var coord = target_coord[i]
				var bandage_pos = get_world_position_from_grid(coord[0],coord[1])
				var claw_inst = instance_create_depth(bandage_pos.x+10,bandage_pos.y+20,-800,obj_beverage_skill_2_bullet)
				claw_inst.target_row = coord[1]
				claw_inst.target_col = coord[0]
			}
		}
		
		if timer >= 41*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	case BOSS_STATE.SKILL3:
		
		sprite_index = spr_beverage_machine_skill_3
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 51
		}
		else{
			image_index = floor(timer/5) mod 51 + 51
		}
		
		if timer == 42*5-1{
			// 创建已选坐标数组
			var selected_coords = [];

			// 循环直到选出4个不同的坐标
			while (array_length(selected_coords) < 4) {
			    // 生成随机坐标
			    var rand_x = irandom_range(1, 7);
			    var rand_y = irandom_range(3, 3);
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
			var target_coord = selected_coords
			for(var i = 0 ; i < array_length(target_coord);i++){
				var coord = target_coord[i]
				var bandage_pos = get_world_position_from_grid(coord[0],coord[1])
				var claw_inst = instance_create_depth(bandage_pos.x+10,bandage_pos.y+20,-800,obj_beverage_skill_3_bullet)
			}
		}
		
		if timer >= 51*5-1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_beverage_machine_appear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 13
		}
		else{
			image_index = floor(timer/5) mod 13 + 13
		}
		if timer == 13 * 5 - 1{
			image_alpha = 0
		}
		if timer == 240{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 2{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
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
		sprite_index = spr_beverage_machine_death
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

