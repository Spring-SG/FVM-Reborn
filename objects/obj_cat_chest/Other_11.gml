for(var i = 0; i < array_length(scared_enemy);i++){
	with scared_enemy[i]{
		if scare_timer <=0 && can_hit(other.target_type,target_type){
			scare_timer = 30
			left_move_flashs = 30
			shield_hp -= shield_max_hp
			hp -= other.atk
			event_user(0)
			if grid_row == 0 {
				if global.row_feature[1] == global.row_feature[0]{
					y_move = global.grid_cell_size_y/left_move_flashs
					grid_row += 1
				}
				else{
					y_move = 0
				}
			}
			else if grid_row == global.grid_rows - 1{
				if global.row_feature[global.grid_rows - 2] == global.row_feature[global.grid_rows - 1]{
					y_move = -global.grid_cell_size_y/left_move_flashs
					grid_row -= 1
				}
				else{
					y_move = 0
				}
			}
			else{
				var im = irandom_range(1,100)
				var up_water = global.row_feature[grid_row - 1] != global.row_feature[grid_row]
				var down_water = global.row_feature[grid_row + 1] != global.row_feature[grid_row]
				if down_water {im = 25}
				if up_water {im = 75}
				if not (up_water && down_water){
					if im > 50{
						y_move = global.grid_cell_size_y/left_move_flashs
						grid_row += 1
					}
					else{
						y_move = -global.grid_cell_size_y/left_move_flashs
						grid_row -= 1
					}
				}
			}
		}
	}
}