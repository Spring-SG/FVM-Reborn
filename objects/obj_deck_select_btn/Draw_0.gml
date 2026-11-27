draw_self()
draw_set_color(c_black)
draw_set_font(font_yuan)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
if obj_readyroom_manager.selected_custom_deck != deck_index{
	if on_click{
		image_alpha = 1
		image_index = 0
	}
	else{
		image_alpha = 0
	}
}
else{
	image_index = 1
	image_alpha = 1
}
draw_set_halign(fa_left)
draw_set_valign(fa_top)