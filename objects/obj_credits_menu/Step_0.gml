// 关闭按钮：只在完全展开后生效（滑动途中画面位置和逻辑位置对不上）
close_hover = false
if (pnl_o >= 0.999) {
	if (point_in_rectangle(mouse_x, mouse_y, close_x1, close_y1, close_x2, close_y2)) {
		close_hover = true
		if (mouse_check_button_released(mb_left)) {
			panel_anim_close(id)
			global.audio.play(snd_button, 0, 0)
			if (instance_exists(obj_player_info_ui)) { obj_player_info_ui.menu_type = 0 }
		}
	}
}
close_s += ((close_hover ? 1 : 0) - close_s) * 0.35