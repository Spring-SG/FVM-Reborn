if global.level_id == "cheese_castle" && obj_battle.current_wave >= 6{
	for(var i = 0 ; i < global.grid_rows ; i++){
		for(var j = 0 ; j < global.grid_cols ; j++){
			if global.grid_terrains[i][j].type == "normal"{
				global.grid_terrains[i][j].type = "water"
			}
		}
	}
}