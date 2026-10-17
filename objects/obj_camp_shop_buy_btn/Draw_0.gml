if is_disabled{
	image_blend = c_gray
}
draw_self()
draw_set_font(font_yuan)
draw_set_color(c_black)
draw_set_halign(fa_left)
draw_set_valign(fa_middle)
draw_text(x-65,y-98,goods_name)
draw_set_font(font_number)
if not is_disabled{
	draw_sprite_ext(spr_craft_material,get_material_info(coin_type).icon,x-50,y-54,0.5,0.5,0,c_white,1)
	draw_set_color(c_white)
	draw_text(x-20,y-54,string(cost))
	if point_in_rectangle(mouse_x,mouse_y,x-210,y-100,x-100,y+30){
		tooltip = true
	}
	else{
		tooltip = false
	}
}
