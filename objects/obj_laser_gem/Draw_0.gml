draw_self()
draw_set_valign(fa_middle)
draw_set_halign(fa_center)
draw_set_font(font_hei)
draw_set_colour(c_white)
if cooldown_timer > 0{
	draw_set_alpha(0.5)
	draw_set_colour(c_black)
	draw_roundrect(x-((sprite_width/2) ),
				   y-((sprite_height/2) ),
				   x+((sprite_width/2)-3 ),
				   y+((sprite_height/2)-3 ),false)
	draw_set_alpha(1)
	draw_set_colour(c_white)
	draw_text(x,y,string(floor(cooldown_timer/60)))
}
//if on_click && cooldown_timer <= 0{
//	draw_set_colour(c_white)
//	draw_set_alpha(0.5)
//	draw_roundrect(x-((sprite_width/2) ),
//				   y-((sprite_height/2) ),
//				   x+((sprite_width/2)-3 ),
//				   y+((sprite_height/2)-3 ),false)
//	draw_set_alpha(1)
//}
if on_click{
	    draw_set_color(c_black)
    draw_set_font(font_pixel);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
	
    var description = gem_info.description
	var display_description = description;
	
	var text_width = string_width_ext(description, 0.65, 180);
    var text_height = string_height_ext(description, 0.65, 180);
    
    var box_width = text_width + 20;
    var box_height = text_height + 15;
	
	if cooldown_timer > 0{
		display_description += "\n正在冷却中"
		box_height += 18
	}

	
	var box_x = x + 40;
	var box_y = y;
	draw_set_color(make_color_rgb(50, 50, 80));
	draw_rectangle(box_x, box_y - box_height/2, box_x + box_width, box_y + box_height/2,  true);
    
	draw_set_color(merge_color(c_yellow,c_white,0.3));
	draw_rectangle(box_x, box_y - box_height/2, box_x + box_width, box_y + box_height/2,  false);
    
	draw_set_color(c_black);
	draw_text(box_x + 10, box_y-box_height/2+7, display_description);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
}
if gem_level>0{
	draw_sprite_ext(spr_star_slot, gem_level-1, x-23, y-23, 0.75, 0.75, 0, c_white, 1)
}