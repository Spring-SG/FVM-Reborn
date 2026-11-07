// ===== 沙尘暴控制器 =====
// 由 obj_event_manager 创建，负责按时间推进沙尘暴的列数，
// 并在被 obj_ventilation_fan 吹散后按初始列数重生。
// 以下参数由 obj_event_manager 创建后覆盖：
//   init_delay        初始生成延迟（秒）
//   init_cols         初始沙尘暴列数
//   advance_interval  每隔多少秒向左侧多生成一列
//   respawn_delay     被吹散后等多少秒按初始列数重生（独立参数，与换气扇的 cycle 无关）
init_delay = 3.0
init_cols = 3
advance_interval = 10.0
respawn_delay = 15.0

// 状态：waiting(等待初始生成) / active(推进中) / blown(已被吹散，等待重生)
state = "waiting"
timer = 0
advance_timer = 0
blow_timer = 0

// 当前最左侧的沙尘暴列；-1 表示还没初始化
left_col = -1
// 已生成的沙尘暴列数（不含地图右侧的补位列）
current_cols = 0

/// 生成一整列沙尘暴
spawn_column = function(_c){
	for(var r = 0 ; r < global.grid_rows ; r++){
		var _pos = get_world_position_from_grid(_c,r)
		instance_create_depth(_pos.x+5,_pos.y-15,-800,obj_desert_sandstorm)
	}
}

/// 向左侧推进一列
spawn_one_column = function(){
	if left_col <= 0{
		return
	}
	left_col --
	current_cols ++
	spawn_column(left_col)
}

/// 地图网格右侧之外也铺满，避免地图右缘出现硬边（与 obj_fog 的 +3 列一致）
spawn_filler = function(){
	for(var c = global.grid_cols ; c < global.grid_cols + 3 ; c++){
		spawn_column(c)
	}
}

/// 按指定列数重新铺开（初始生成 / 被吹散后重生）
spawn_columns = function(_count){
	spawn_filler()
	for(var i = 0 ; i < _count ; i++){
		spawn_one_column()
	}
}

/// 被换气扇吹散：停止推进，等 respawn_delay 秒后按初始列数重生
on_blown = function(){
	if state == "blown"{
		return
	}
	state = "blown"
	blow_timer = max(0,respawn_delay) * 60
}