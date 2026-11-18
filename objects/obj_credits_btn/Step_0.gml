// 悬停：菜单空闲（menu_type == 0）且鼠标落在按钮矩形内
var _in = false
if (global.menu_screen && instance_exists(obj_player_info_ui)) {
	_in = (obj_player_info_ui.menu_type == 0)
}
if (_in) {
	_in = point_in_rectangle(mouse_x, mouse_y, x - bw_half, y - bh_half, x + bw_half, y + bh_half)
}
hover += ((_in ? 1 : 0) - hover) * 0.35
hover = clamp(hover, 0, 1)

// 点击：按下与松开都落在按钮内才算一次（和 obj_quit_confirm / obj_pause_menu 一样用松开判定，
// 纯绘制的按钮没有精灵遮罩，按下/松开位置都要自己校验）
if (_in && mouse_check_button(mb_left)) { armed = true }
if (mouse_check_button_released(mb_left)) {
	if (armed && _in) {
		obj_player_info_ui.menu_type = 9   // 由 obj_player_info_ui 的 Step 创建致谢页面
		global.audio.play(snd_button, 0, 0)
	}
	armed = false
}