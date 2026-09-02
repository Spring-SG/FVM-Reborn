draw_self()
draw_set_font(font_yuan)
draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_middle)
draw_text(x-280,y,btn_text)
if obj_cookbook_bg.button_select == btn_index{
	image_index = 2
}
else{
	if on_click{
		image_index = 1
	}
	else{
		image_index = 0
	}
}