if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if state == "appear"{
	image_index = floor(timer/5) mod 6
	if timer >= 6 * 5 - 1{
		timer = 0
		state = "idle"
		
	}
}
else if state == "idle"{
	image_index = 5
	if timer == 45{
		var inst = instance_create_depth(x,y-60,-800,obj_engineer_bullet_effect)
		inst.sprite_index = spr_messenger_fog
		var inst2 = instance_create_depth(x-global.grid_cell_size_x,y-60,-800,obj_engineer_bullet_effect)
		inst2.sprite_index = spr_messenger_fog
		var inst3 = instance_create_depth(x+global.grid_cell_size_x,y-60,-800,obj_engineer_bullet_effect)
		inst3.sprite_index = spr_messenger_fog
		var inst4 = instance_create_depth(x,y-60-global.grid_cell_size_y,-800,obj_engineer_bullet_effect)
		inst4.sprite_index = spr_messenger_fog
		var inst5 = instance_create_depth(x,y-60+global.grid_cell_size_y,-800,obj_engineer_bullet_effect)
		inst5.sprite_index = spr_messenger_fog
	}
	if timer == 180{
		with obj_card_parent{
			if((abs(grid_col - other.grid_col) + abs(grid_row - other.grid_row)) <= 1 && plant_id != "player" &&  plant_type != "coffee"){
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
		hp = 0
	}
}
else if state == "death"{
	image_index = 5
	image_alpha -= 0.1
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

var base_depth = -10 - (zombie_grid.row * 45) - (8 * 5);
depth = base_depth ; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;