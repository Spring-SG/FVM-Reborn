// 绘制悬停提示（已优化）
if global.is_paused{
	exit
}
if (hover_alpha > 0) {
    //draw_set_alpha(hover_alpha);
   
    draw_set_color(c_black)
    draw_set_font(font_pixel);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    
    var text_width = string_width_ext(description, 0.65, 180);
    var text_height = string_height_ext(description, 0.65, 180);
    
    var box_width = text_width + 20;
    var box_height = text_height + 15;
	var display_description = description;
	if (!is_ready && global.flame < current_cost && cooldown_timer >= cooldown) {
		box_height += text_height 
		display_description = description + "\n没有足够的火苗" 
	}
	else if (!is_ready &&  cooldown_timer < cooldown) {
		box_height += text_height 
		display_description = description + "\n正在冷却中" 
	}
	if slot_index <= 14{
		var box_x = x;
		draw_set_halign(fa_center);
		draw_set_valign(fa_top);
	
	    var box_y = y + 60;
	    draw_set_color(make_color_rgb(50, 50, 80));
	    draw_rectangle(box_x-box_width/2, box_y, box_x + box_width/2, box_y + box_height,  true);
    
	    draw_set_color(merge_color(c_yellow,c_white,0.3));
	    draw_rectangle(box_x-box_width/2, box_y, box_x + box_width/2, box_y + box_height,  false);
    
	    draw_set_color(c_black);
	    draw_text(box_x , box_y + 7, display_description);
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
	    draw_set_alpha(1);
	}
	else{
		var box_x = x - box_width-47;
	    var box_y = y + 25;
	    draw_set_color(make_color_rgb(50, 50, 80));
	    draw_rectangle(box_x, box_y, box_x + box_width, box_y + box_height,  true);
    
	    draw_set_color(merge_color(c_yellow,c_white,0.3));
	    draw_rectangle(box_x, box_y, box_x + box_width, box_y + box_height,  false);
    
	    draw_set_color(c_black);
	    draw_text(box_x + 10, box_y + 7, display_description);
	    draw_set_halign(fa_left);
	    draw_set_valign(fa_top);
	    draw_set_alpha(1);
	}
}