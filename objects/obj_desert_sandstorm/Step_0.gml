if global.is_paused{
	exit
}

// ---- 精灵动画 ----
anim_timer ++
if anim_timer >= anim_delay{
	anim_timer = 0
	if state == "appear"{
		anim_frame ++
		if anim_frame > frame_appear_end{
			anim_frame = frame_loop_start
			state = "idle"
		}
	}
	else if state == "idle"{
		anim_frame ++
		if anim_frame > frame_loop_end{
			anim_frame = frame_loop_start
		}
	}
	else{
		anim_frame ++
		if anim_frame > frame_vanish_last{
			instance_destroy()
			exit
		}
	}
}
image_index = anim_frame

// ---- 网格位置 ----
var gp = get_grid_position_from_world(x,y)
col = gp.col
row = gp.row

// ---- 阻止卡片放置：把格子特性改成 obstacle（同 obj_barrier） ----
if !grid_claimed && col >= 0 && col < global.grid_cols && row >= 0 && row < global.grid_rows{
	if global.grid_terrains[row][col].type != "obstacle"{
		current_grid_type = global.grid_terrains[row][col].type
		global.grid_terrains[row][col].type = "obstacle"
	}
	grid_claimed = true
}