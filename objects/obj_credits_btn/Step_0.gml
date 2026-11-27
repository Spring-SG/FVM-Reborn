// 悬停：菜单空闲（menu_type == 0）且鼠标落在按钮绘制矩形内
var _in = false
if (global.menu_screen && instance_exists(obj_player_info_ui)) {
	_in = (obj_player_info_ui.menu_type == 0)
}
if (_in) {
	_in = point_in_rectangle(mouse_x, mouse_y, x - dx, y - dy, x - dx + dw, y - dy + dh)
}
hover = _in
image_index = _in ? 1 : 0

// 点击：按下与松开都落在按钮内才算一次（和 obj_quit_confirm / obj_pause_menu 一样用松开判定）
if (_in && mouse_check_button(mb_left)) { armed = true }
if (mouse_check_button_released(mb_left)) {
	if (armed && _in) {
		obj_player_info_ui.menu_type = 9   // 由 obj_player_info_ui 的 Step 创建致谢页面
		global.audio.play(snd_button, 0, 0)
	}
	armed = false
}
