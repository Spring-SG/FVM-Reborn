if on_click{
	var _tt_left = (x >= 600);
		draw_set_font(font_yuan);
		tooltip_set(_tt_left ? mouse_x - 15 : mouse_x + 15, mouse_y - 25, tooltip_text, _tt_left ? -1 : 1);
}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();