// ===== 沙漠龙卷风 =====
// 以下参数由 obj_event_manager 创建后覆盖
//   col / row       初始列、行
//   x_speed/y_speed 每帧位移（像素）
col = 8
row = 3
x_speed = -1
y_speed = 0

// 贴图与动画
sprite_index = spr_desert_tornado
image_speed = 0
image_index = 0
image_alpha = 0
image_xscale = 1.8
image_yscale = 1.8

anim_timer = 0
anim_delay = 5			// 每 5 帧推进一帧精灵（贴图本身按 12fps 设计）

// 淡入 / 淡出速度
fade_in_speed = 0.04
fade_out_speed = 0.04

// 状态：appear(淡入中) / move(移动并摧毁卡片) / vanish(已出图，淡出)
state = "appear"

// 浮点网格坐标，用于平滑移动与命中判定；首帧由 col / row 初始化
grid_col_f = 0
grid_row_f = 0
grid_init = false

depth = -750

/// 摧毁「本格」和「本列上一行」两格里的卡片
/// 约束：player / coffee / 无敌 / 棉花糖 / 被保护沙拉庇护 的卡片不受影响
destroy_cards_in_grid = function(){
	var _col = floor(grid_col_f)
	var _row = floor(grid_row_f)
	if _col < 0 || _col >= global.grid_cols{
		return
	}
	for(var i = 0 ; i < 2 ; i++){
		var _target_row = _row - i
		if _target_row < 0 || _target_row >= global.grid_rows{
			continue
		}
		with obj_card_parent{
			if grid_col == _col && grid_row == _target_row
			&& plant_id != "player" && plant_type != "coffee" && !invincible
			&& plant_id != "cotton_candy" && !desert_wind_protect{
				// 被卷走的卡片留一个上飘的残影（用卡片自身的位置与层级）
				var _eff = instance_create_depth(x,y,depth,obj_drop_death_effect)
				_eff.sprite_index = sprite_index
				_eff.image_index = image_index
				_eff.x_move = other.x_speed * 3
				_eff.y_move = -3
				instance_destroy()
			}
		}
	}
}