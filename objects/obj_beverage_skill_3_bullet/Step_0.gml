if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++
death_timer++
if death_timer >= 3*60 && state != "death" && hp > 0 && state != "act"{
	timer = 0
	state = "act"
}

if state == "appear"{
	image_index = 0
	y += y_speed
	x += x_speed
}
else if state == "anim"{
	image_index = floor(timer/5) mod 7
	if timer == 4 * 5 + 2{
		with obj_card_parent{
			if grid_col == other.grid_col && grid_row == other.grid_row &&
			plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
	}
	if timer >= 7*5 - 1{
		timer = 0
		state = "idle"
	}
}
else if state == "idle"{
	image_index = floor(timer/5) mod 10 + 7
}
else if state == "death"{
	image_index = 16
	image_alpha -= 0.1
}
else if state == "act"{
	image_index = floor(timer/5) mod 7 + 17
	if timer >= 7 * 5 - 1{
		with obj_card_parent{
			if grid_col == other.grid_col &&
			plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		var inst = instance_create_depth(x,y,-800,obj_coke_bomb_explode)
		inst.sprite_index = spr_beverage_machine_skill_3_bullet_explode
		instance_destroy()
	}
}

if hp <= 0 && state != "death"{
	state = "death"
	timer = 0
}

if image_alpha <= 0 && hp <= 0{
	instance_destroy()
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

if state != "appear"{
	//if global.grid_terrains[grid_pos.row][grid_pos.col].type != "obstacle"{
	//	current_grid_type = global.grid_terrains[grid_pos.row][grid_pos.col].type
	//	global.grid_terrains[grid_pos.row][grid_pos.col].type = "obstacle"
	//}

}