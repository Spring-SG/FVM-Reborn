draw_self()
if unlock{
	image_blend = c_white
	if on_click{
		var shader_x = x;
		var shader_y = y + 5;
		
		if (global.map_id == "volcanic_island") {
			shader_y -= 2;
		}

		if (variable_struct_exists(special_boss_levels, target_level_id)) {
			shader_x += 5;
			shader_y += 5;
		}
		draw_sprite_ext(spr_button_shader_2,0,shader_x,shader_y,1.8,1.8,0,c_white,0.3)
	}
}
else{
	image_blend = merge_colour(c_white,c_black,0.5)
}
if pressed{
	//draw_set_alpha(0.5);
	//	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	//	draw_set_alpha(1);
    //    // 只显示"暂停中"文字
	//	draw_set_font(font_yuan)
    //    draw_set_halign(fa_center);
    //    draw_set_valign(fa_middle);
	//	draw_set_color(c_white)
	//	draw_text(room_width / 2, room_height / 2, "加载中……");
}