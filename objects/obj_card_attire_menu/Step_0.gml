if !info_got{
	card_attire_id_list = get_card_attire_list(target_card_id)//获取卡片时装列表
	selected_attire_id = card_equipped_attire_id(target_card_id)//获取卡片当前装备时装
	if selected_attire_id != -1{
		selected_attire_index = array_get_index(card_attire_id_list,selected_attire_id)
	}
	var btn4 = instance_create_depth(x-80,y-5,depth-1,obj_card_attire_select_btn)
	btn4.type = "prev"

	var btn5 = instance_create_depth(x+80,y-5,depth-1,obj_card_attire_select_btn)
	btn5.type = "next"
	info_got = true
}

// 时装切换动画：首帧静默同步，之后检测索引变化、定方向、推进计时
if sw_shown == -2{
	sw_shown = selected_attire_index
	sw_from  = sw_shown
}
else if sw_shown != selected_attire_index{
	sw_from  = sw_shown
	sw_shown = selected_attire_index
	sw_t     = 0
	if sw_pending_dir != 0{
		sw_dir = sw_pending_dir      // 以按下的箭头为准：只有"无"+一档时按序号差算不出方向
		sw_pending_dir = 0
	}
	else{
		var _n       = array_length(card_attire_id_list) + 1
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

