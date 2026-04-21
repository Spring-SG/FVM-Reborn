if (global.level_id == "cheese_castle" && obj_battle.current_wave >= 6)
||((global.level_id == "tower_cake_10_1" || global.level_id == "tower_cake_10_2") && obj_battle.current_wave >= 2){
	for(var i = 0 ; i < global.grid_rows ; i++){
		for(var j = 0 ; j < global.grid_cols ; j++){
			if !((i == 1 || i == 5)&&j==6){
				global.grid_terrains[i][j].type = "water"
			}
		}
	}
}
if is_real(global.level_file.version){
	if global.level_file.version >= 1.5{
		var event_list = global.level_file.events
		for(var event_index = 0 ; event_index < array_length(event_list) ; event_index++){
			if event_list[event_index].id == "tide_cheese_castle"{
				if obj_battle.current_wave >= event_list[event_index].target_wave{
					for(var i = 0 ; i < global.grid_rows ; i++){
						for(var j = 0 ; j < global.grid_cols ; j++){
							if !((i == 1 || i == 5)&&j==6){
								global.grid_terrains[i][j].type = "water"
							}
						}
					}
				}
			}
		}
	}
}