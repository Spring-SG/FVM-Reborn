if global.is_paused{
	exit
}

if !grid_init{
	grid_col_f = col
	grid_row_f = row
	grid_init = true
}

// ---- 精灵动画（12 帧循环） ----
anim_timer ++
if anim_timer >= anim_delay{
	anim_timer = 0
	image_index = (image_index + 1) mod sprite_get_number(sprite_index)
}

// ---- 状态机 ----
if state == "appear"{
	// 淡入生成
	image_alpha += fade_in_speed
	if image_alpha >= 1{
		image_alpha = 1
		state = "move"
	}
}
else if state == "vanish"{
	// 已跑出地图，淡出消失
	image_alpha -= fade_out_speed
	if image_alpha <= 0{
		instance_destroy()
		exit
	}
}
else{
	// ---- 移动 ----
	grid_col_f += x_speed / global.grid_cell_size_x
	grid_row_f += y_speed / global.grid_cell_size_y

	// ---- 摧毁本格与本列上一行的卡片 ----
	destroy_cards_in_grid()

	// ---- 移动到地图网格之外后淡出消失 ----
	var _col = floor(grid_col_f)
	var _row = floor(grid_row_f)
	if _col < 0 || _col >= global.grid_cols || _row < 0 || _row >= global.grid_rows{
		state = "vanish"
	}
}

// ---- 世界坐标：贴图原点在底部中央，底边对齐格子底边 ----
x = global.grid_offset_x + (grid_col_f + 0.5) * global.grid_cell_size_x
y = global.grid_offset_y + (grid_row_f + 0.9) * global.grid_cell_size_y
