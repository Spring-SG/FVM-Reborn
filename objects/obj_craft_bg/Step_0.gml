if close_timer > 0{
	close_timer --
}
if close_timer == 0{
	// 反向滑出 + 淡出；播完由 panel_anim_step 销毁（close_timer 归位，别每帧重复触发）
	panel_anim_close(id)
	close_timer = -1
}