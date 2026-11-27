// 鼠标右键退出（ESC 由 obj_menu_manager / obj_map_manager 的 ESC 链负责）
if (!pnl_closing && mouse_check_button_released(mb_right)) {
	panel_anim_close(id)
	global.audio.play(snd_button, 0, 0)
	if (instance_exists(obj_player_info_ui)) { obj_player_info_ui.menu_type = 0 }
}

// 链接按钮：完全展开后才响应（滑动途中画面位置和逻辑位置对不上）
btn_hover = -1
if (pnl_o >= 0.999) {
	for (var i = 0; i < array_length(links); i++) {
		var _bx = btn_x0 + i * (btn_w + btn_gap)
		if (point_in_rectangle(mouse_x, mouse_y, _bx, btn_y - btn_h * 0.5, _bx + btn_w, btn_y + btn_h * 0.5)) {
			btn_hover = i
			break
		}
	}
}

// 按下与松开都落在同一个按钮上才算一次（和项目里其它按钮一致，用松开判定）
if (btn_hover >= 0 && mouse_check_button(mb_left)) { btn_armed = btn_hover }
if (mouse_check_button_released(mb_left)) {
	if (btn_armed >= 0 && btn_armed == btn_hover) {
		global.audio.play(snd_button, 0, 0)
		url_open(links[btn_armed][1])     // 交给系统默认浏览器
	}
	btn_armed = -1
}
