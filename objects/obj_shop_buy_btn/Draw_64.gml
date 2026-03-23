if tooltip{
	if tooltip_text != ""{
		// 获取鼠标位置
		var tooltip_x = mouse_x - 15;
		var tooltip_y = mouse_y - 25;
		if x < 600{
			tooltip_x = mouse_x + 15;
			tooltip_y = mouse_y - 25;
		}
		
		
		draw_set_font(font_yuan)
		// 绘制提示背景
		draw_set_color(c_black);
		draw_set_alpha(0.7);
		if x >= 600{
			draw_rectangle(tooltip_x + 5, tooltip_y - 5, 
		                tooltip_x - string_width(tooltip_text)-5, tooltip_y + string_height(tooltip_text)+5, false);
		}
		else{
			draw_rectangle(tooltip_x - 5, tooltip_y - 5, 
		                tooltip_x + string_width(tooltip_text)+5, tooltip_y + string_height(tooltip_text)+5, false);
		}
        
		// 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_alpha(1);
		draw_set_color(c_white);
		if x >= 600{	
			draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
		}
		else{
			draw_text(tooltip_x, tooltip_y, tooltip_text);
		}
	
		draw_set_valign(fa_top)
	}
}