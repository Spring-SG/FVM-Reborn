draw_self()
// 在绘制自身之后添加悬停提示
if (point_in_rectangle(mouse_x, mouse_y, x-20, y-20, x+20, y+20) && tooltip_text != "") {
	tooltip_set(mouse_x + 15, mouse_y - 15 - string_height(tooltip_text) / 2, tooltip_text, 1, 0.5);
	}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();