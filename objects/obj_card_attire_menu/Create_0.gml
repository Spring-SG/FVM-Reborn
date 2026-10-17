image_xscale = 1.8
image_yscale = 1.8

target_card_id = ""
info_got = false
card_attire_id_list = []
selected_attire_id = ""
selected_attire_index = -1 // 当前选择的时装索引

//target_current_level = 9
//target_current_shape = 0
//target_current_skill = 0

// 时装切换动画（与设置面板难度名同一套做法：窗口内左右滑动 + 裁剪窗口）
sw_shown  = -2                 // -2 = 还没同步过：首帧 Step 会把当前装备的那档填进来，不触发动画
sw_from   = -1
sw_t      = -1
sw_frames = 18
sw_dir    = 1
sw_pending_dir = 0          // 按钮按下时写入本次方向，Step 消费后清零

sw_surf   = -1
sw_win_l  = x - 175            // 窗口 = 面板精灵内层浅蓝区（357x234，原点 178,117，缩放 1.8）
sw_win_t  = y - 122
sw_win_w  = 349
sw_win_h  = 310

function card_attire_content_draw(_index, _dx, _dy){
	if _index != -1{
		var _id = card_attire_id_list[_index]
		var _d  = get_attire_info(_id)
		draw_sprite_ext(spr_slot, 0, x + _dx, y - 10 + _dy, 0.32, 0.32, 0, c_white, 1)
		draw_sprite(_d.icon, 0, x + _dx, y + 10 + _dy)
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_text(x + _dx, y + 70 + _dy, _d.name)
	}
	else{
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_text(x + _dx, y + 70 + _dy, "无")
	}
}
