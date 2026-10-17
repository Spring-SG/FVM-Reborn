// 检查输入框内容是否变化
if (input_field.text != character_name) {
    character_name = input_field.text;
}

// 时装切换动画：检测索引变化、定方向、推进计时
if sw_shown != selected_attire_index{
	sw_from  = sw_shown
	sw_shown = selected_attire_index
	sw_t     = 0
	if sw_pending_dir != 0{
		sw_dir = sw_pending_dir      // 以按下的箭头为准：只有"无"+一档时按序号差算不出方向
		sw_pending_dir = 0
	}
	else{
		var _n       = array_length(player_attire_id_list) + 1
		var _pos_new = (selected_attire_index + 1 + _n) mod _n
		var _pos_old = (sw_from + 1 + _n) mod _n
		sw_dir = (((_pos_new - _pos_old) + _n) mod _n == 1) ? 1 : -1
	}
}
// 动效等级 < 2：不播滑动，sw_t 立刻收回 -1（Draw_0 走 sw_t < 0 的静态分支直接画新档）；方向也一并清掉
if (!ui_anim_on(1)){
	sw_t = -1
	sw_pending_dir = 0
}
if sw_t >= 0{
	sw_t++
	if sw_t >= sw_frames sw_t = -1
}

