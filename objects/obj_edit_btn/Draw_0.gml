draw_self()
if on_click{
	// 获取鼠标位置
	
	tooltip_x = x + 80;
	tooltip_y = y - 25;
	
	var tooltip_text = "编辑菜单\n此处可以更换角色时装"
	
		
	draw_set_font(font_yuan)
	// 绘制提示背景
	draw_set_color(c_black);
	draw_set_alpha(0.7);
	draw_rectangle(tooltip_x - 5, tooltip_y - 5, 
		            tooltip_x + string_width(tooltip_text)+5, tooltip_y + string_height(tooltip_text)+5, false);
        
	// 绘制提示文本
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text(tooltip_x, tooltip_y, tooltip_text);
	
	draw_set_valign(fa_top)
}