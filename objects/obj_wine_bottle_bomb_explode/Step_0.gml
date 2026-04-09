if global.is_paused{
	exit
}
timer++
if timer < max_time{
	image_index = floor(timer/5)
}
else{
	instance_destroy()
}
if interval > 1{
	if type == 0 && timer == 2{
		if is_parent{
			if col > 0{
				var inst1 = instance_create_depth(x-global.grid_cell_size_x,y,depth,obj_wine_bottle_bomb_explode)
				inst1.col = col - 1
				inst1.dir = 0
				inst1.interval = interval - 1
			}
			if col < global.grid_cols - 1{
				var inst1 = instance_create_depth(x+global.grid_cell_size_x,y,depth,obj_wine_bottle_bomb_explode)
				inst1.col = col + 1
				inst1.dir = 1
				inst1.interval = interval - 1
			}
		}
		else{
			if col > 0 && dir == 0{
				var inst1 = instance_create_depth(x-global.grid_cell_size_x,y,depth,obj_wine_bottle_bomb_explode)
				inst1.col = col - 1
				inst1.dir = 0
				inst1.interval = interval - 1
			}
			if col < global.grid_cols - 1 && dir == 1{
				var inst1 = instance_create_depth(x+global.grid_cell_size_x,y,depth,obj_wine_bottle_bomb_explode)
				inst1.col = col + 1
				inst1.dir = 1
				inst1.interval = interval - 1
			}
		}
	}
	if type == 1 && timer == 2{
		if is_parent{
			if row > 0{
				var inst1 = instance_create_depth(x,y-global.grid_cell_size_y,depth,obj_wine_bottle_bomb_explode)
				inst1.row = row - 1
				inst1.dir = 0
				inst1.type = 1
				inst1.interval = interval - 1
			}
			if row < global.grid_rows - 1{
				var inst1 = instance_create_depth(x,y+global.grid_cell_size_y,depth,obj_wine_bottle_bomb_explode)
				inst1.row = row + 1
				inst1.dir = 1
				inst1.type = 1
				inst1.interval = interval - 1
			}
		}
		else{
			if row > 0 && dir == 0{
				var inst1 = instance_create_depth(x,y-global.grid_cell_size_y,depth,obj_wine_bottle_bomb_explode)
				inst1.row = row - 1
				inst1.dir = 0
				inst1.type = 1
				inst1.interval = interval - 1
			}
			if row < global.grid_rows - 1 && dir == 1{
				var inst1 = instance_create_depth(x,y+global.grid_cell_size_y,depth,obj_wine_bottle_bomb_explode)
				inst1.row = row + 1
				inst1.dir = 1
				inst1.type = 1
				inst1.interval = interval - 1
			}
		}
	}
}