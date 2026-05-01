
draw_self()
// 绘制标题
draw_set_color(c_white)
draw_set_font(font_yuan); // 使用菜单字体
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y - 165, "卡片时装选择");
// 绘制文字
if selected_attire_index != -1{
	selected_attire_id = card_attire_id_list[selected_attire_index]
	var attire_data = get_attire_info(selected_attire_id)
	draw_sprite_ext(spr_slot,0,x,y-10,0.32,0.32,0,c_white,1)
	draw_sprite(attire_data.icon,0,x,y+10)
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(x,y+70,attire_data.name)
}
else{
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(x,y+70,"无")
}