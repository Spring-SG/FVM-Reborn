if global.is_paused{
	exit
}

var grid_pos = get_grid_position_from_world(x,y)

if flash_value > 0{
	flash_value -= 10
}

timer++

if flame_collect >= 500 && hp > 0 && state != "death"{
	for(var __count__ = 0 ; __count__ < 1 ; __count__++){
		var can_summon = true
		for(var hole_try_count = 0 ; hole_try_count < 100;hole_try_count++){
			can_summon = true
			var pos_x = irandom_range(0,global.grid_cols-1)
			var pos_y = irandom_range(0,global.grid_rows-1)
			var cave_pos = get_world_position_from_grid(pos_x,pos_y)
			var plant_list = ds_grid_get(global.grid_plants,cave_pos.col,cave_pos.row)
			with obj_face_cookie{
				var pos1 = get_grid_position_from_world(x,y)
				if(pos1.row == cave_pos.row && pos1.col == cave_pos.col){
					can_summon = false
				}
			}
			if ds_list_size(plant_list)>0 or global.grid_terrains[cave_pos.row][cave_pos.col].type == "obstacle"{
				can_summon = false
			}
			if can_summon{
				var inst = instance_create_depth(cave_pos.x,cave_pos.y+15,-5,obj_face_cookie)
				inst.sprite_index = sprite_index
				break
			}
		}
	}
	flame_collect = 0
}


if state == "appear"{
	image_index = floor(timer/5) mod 10
	if timer >= 10*5 - 1{
		timer = 0
		state = "idle"
	}
}
else if state == "anim"{
	if hp > maxhp * hurt_rate{
		image_index = floor(timer/5) mod 11 + 20
	}
	else{
		image_index = floor(timer/5) mod 11 + 41
	}
	with obj_flame{
		is_collected = false
		is_capture = true
		speed = 15
		if global.is_paused{
			speed = 0
		}
		direction = point_direction(x,y,other.x,other.y-125)
		if (abs(x - other.x)<=10 && abs(y - other.y+125)<=10){
			other.flame_collect += value
			instance_destroy()
		}
	}
	if timer >= 5 * 60{
		with obj_flame{
			is_capture = false
			speed = 0
		}
		timer = 0
		state = "idle"
	}
}
else if state == "idle"{
	if hp > maxhp * hurt_rate{
		image_index = floor(timer/5) mod 10 + 10
	}
	else{
		image_index = floor(timer/5) mod 10 + 31
	}
	if timer >= 8 * 60{
		timer = 0
		state = "anim"
	}
}
else if state == "death"{
	image_index = floor(timer/5) mod 15 + 52
	if timer >= 15 * 5 - 1{
		image_index = 66
		image_alpha -= 0.1
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