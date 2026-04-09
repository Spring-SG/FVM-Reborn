if (global.level_id == "cheese_castle" && obj_battle.current_wave >= 6)
||((global.level_id == "tower_cake_9_1" || global.level_id == "tower_cake_9_2") && obj_battle.current_wave >= 2){
	for(var i = 0 ; i < global.grid_rows ; i++){
		for(var j = 0 ; j < global.grid_cols ; j++){
			if !((i == 1 || i == 5)&&j==6){
				global.grid_terrains[i][j].type = "water"
			}
		}
	}
}