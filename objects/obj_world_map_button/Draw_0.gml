if global.menu_screen{
	draw_self()
	draw_sprite_ext(spr_map_name_display, 0, x, y+85, 0.9, 0.9, 0, c_white, 1)
	draw_set_color(c_white)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_font(font_yuan)
	if room == room_menu{
		draw_text(x,y+88,"美味镇")
	}
	else {
		draw_text(x,y+88,global.map_name)
	}
}