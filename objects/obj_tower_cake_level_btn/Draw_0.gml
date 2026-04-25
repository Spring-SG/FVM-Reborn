if !is_unlocked{
	image_blend = c_gray
}
else{
	image_blend = c_white
}
draw_self()
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_colour(image_blend)
draw_set_font(font_number)
draw_text(x,y,btn_text)