// 退场时还原格子特性（参考 obj_barrier 的 Destroy）
if grid_claimed && current_grid_type != ""{
	if col >= 0 && col < global.grid_cols && row >= 0 && row < global.grid_rows{
		global.grid_terrains[row][col].type = current_grid_type
	}
}