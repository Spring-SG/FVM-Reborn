if global.is_paused{
	exit
}

if left_col < 0{
	left_col = global.grid_cols
}

if state == "waiting"{
	// 初始生成延迟结束后，立即生成指定列数
	timer ++
	if timer >= init_delay * 60{
		spawn_columns(init_cols)
		state = "active"
		advance_timer = 0
	}
}
else if state == "active"{
	// 每隔推进间隔向左侧多生成一列
	advance_timer ++
	if advance_timer >= advance_interval * 60{
		advance_timer = 0
		spawn_one_column()
	}
}
else if state == "blown"{
	// 被吹散期间不推进，倒计时结束后按初始列数重新铺开
	blow_timer --
	if blow_timer <= 0{
		left_col = global.grid_cols
		current_cols = 0
		spawn_columns(init_cols)
		state = "active"
		advance_timer = 0
	}
}