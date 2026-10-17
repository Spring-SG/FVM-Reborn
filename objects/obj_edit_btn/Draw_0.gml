draw_self()
if on_click{
	draw_set_font(font_yuan);
		tooltip_set(x + 80, y - 25, "编辑菜单\n此处可以更换角色时装", 1);
}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();