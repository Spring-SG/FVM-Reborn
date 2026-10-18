if is_disabled{
	image_blend = c_gray
}
draw_self()
draw_set_font(font_yuan)
draw_set_color(c_black)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_alpha(ui_anim_alpha(id) * image_alpha)	// 文字不吃 image_alpha：面板淡入 × 自己入场淡入
draw_text(x+3,y - 110 * pg_pop,goods_name)
draw_set_font(font_number)
if not is_disabled{
	draw_set_color(c_yellow)
	draw_text(x,y - 62 * pg_pop,string(cost)+"G")
}
draw_set_alpha(1)
