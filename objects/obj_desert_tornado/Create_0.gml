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

// 每张卡片的「连续接触帧数」：key = 卡片实例 id 字符串，value = 帧数
// 卡片刚放下那一帧，防风草可能还没跑到给自己的 Step，此时不该直接判定死亡；
// 只有连续接触满 desert_wind_contact_delay 帧才卷走卡片。
contact_frames = {}
desert_wind_contact_delay = 3	// 第 3 帧起才会摧毁（接触帧算第 1 帧）

/// 摧毁「本格」和「本列上一行」两格里的卡片
/// 约束：player / coffee / 无敌 / 棉花糖 / 被保护沙拉庇护 的卡片不受影响；
///       且必须连续接触满 desert_wind_contact_delay 帧。第 3 帧起才会摧毁。
destroy_cards_in_grid = function(){
	var _col = floor(grid_col_f)
	var _row = floor(grid_row_f)
	if _col < 0 || _col >= global.grid_cols{
		return
	}
	var _hit = {}
	for(var i = 0 ; i < 2 ; i++){
		var _target_row = _row - i
		if _target_row < 0 || _target_row >= global.grid_rows{
			continue
		}
		with obj_card_parent{
			if grid_col == _col && grid_row == _target_row
			&& plant_id != "player" && plant_type != "coffee" && !invincible
			&& plant_id != "cotton_candy" && !desert_wind_protect{
				var _key = string(id)
				_hit[$ _key] = true
				if !variable_struct_exists(other.contact_frames, _key){
					other.contact_frames[$ _key] = 0
				}
				var _frames = other.contact_frames[$ _key] + 1
				other.contact_frames[$ _key] = _frames

				if _frames >= other.desert_wind_contact_delay{
					// 被卷走的卡片留一个上飘的残影（用卡片自身的位置与层级）
					var _eff = instance_create_depth(x,y,depth,obj_drop_death_effect)
					_eff.sprite_index = sprite_index
					_eff.image_index = image_index
					_eff.x_move = other.x_speed * 3
					_eff.y_move = -3
					variable_struct_remove(other.contact_frames, _key)
					instance_destroy()
				}
			}
		}
	}

	// 本帧已不再接触（被保护 / 已离开格子 / 已消失）的卡片，接触计数清零，
	// 保证计数只统计「连续」接触
	var _keys = variable_struct_get_names(contact_frames)
	for(var k = 0 ; k < array_length(_keys) ; k++){
		if !variable_struct_exists(_hit, _keys[k]){
			variable_struct_remove(contact_frames, _keys[k])
		}
	}
}