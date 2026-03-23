if is_disabled{
	image_blend = c_gray
}
draw_self()
draw_set_font(font_yuan)
draw_set_color(c_black)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text(x,y-108,goods_name)
if not is_disabled{
	draw_set_color(c_yellow)
	draw_text(x,y-62,string(cost)+"G")
	if point_in_rectangle(mouse_x,mouse_y,x-280,y-120,x-120,y-20){
		tooltip = true
	}
	else{
		tooltip = false
	}
}
