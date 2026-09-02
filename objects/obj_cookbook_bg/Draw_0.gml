draw_set_alpha(0.5);
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

if button_select < 0{
	draw_set_font(font_yuan)
	draw_set_colour(c_black)
	draw_set_halign(fa_left)
	draw_set_valign(fa_middle)
	draw_text(x+230,y-260,"未选择食谱类型")
	draw_text(x+240,y-165,"点击左侧选项卡以选择食谱类型")
	draw_text(x+230,y+33,"未选择食谱类型")
	draw_text(x+240,y+128,"点击左侧选项卡以选择食谱类型")
}
else{
	var cookbook_rank_list = global.save_data.equipped_cookbook[button_select]
	var cookbook_material = ["copper_cookbook_fragment","silver_cookbook_fragment","gold_cookbook_fragment"]
	var max_cookbook_slot = clamp(get_material_amount(cookbook_material[button_select]),0,2)
	draw_set_font(font_yuan)
	draw_set_colour(c_black)
	draw_set_halign(fa_left)
	draw_set_valign(fa_middle)
	if max_cookbook_slot <= 0{
		draw_text(x+230,y-260,"食谱槽位未解锁")
		var cm_data = get_material_info(cookbook_material[button_select])
		draw_text(x+240,y-165,$"获取1个{cm_data.name}以解锁此槽位")
	}
	else{
		if array_length(cookbook_rank_list) >= 1{
			var cdata = get_cookbook_data(cookbook_rank_list[0])
			draw_text(x+230,y-285,cdata.title)
			draw_text(x+230,y-235,cdata.tiny_desc)
			draw_set_valign(fa_top)
			draw_text(x+230,y-178,cdata.desc)
			draw_sprite_ext(spr_cookbook_icon,cdata.icon,x+150,y-260,1.8,1.8,0,c_white,1)
		}
		else{
			draw_text(x+230,y-260,"未装配食谱")
			draw_text(x+240,y-165,"在左侧食谱列表中装配食谱")
		}
	}
	if max_cookbook_slot <= 1{
		draw_text(x+230,y+33,"食谱槽位未解锁")
		var cm_data = get_material_info(cookbook_material[button_select])
		draw_text(x+240,y+128,$"获取2个{cm_data.name}以解锁此槽位")
	}
	else{
		if array_length(cookbook_rank_list) >= 2{
			var cdata = get_cookbook_data(cookbook_rank_list[1])
			draw_set_valign(fa_middle)
			draw_text(x+230,y+8,cdata.title)
			draw_text(x+230,y+58,cdata.tiny_desc)
			draw_set_valign(fa_top)
			draw_text(x+230,y+115,cdata.desc)
			draw_sprite_ext(spr_cookbook_icon,cdata.icon,x+150,y+33,1.8,1.8,0,c_white,1)
		}
		else{
			draw_set_valign(fa_middle)
			draw_text(x+230,y+33,"未装配食谱")
			draw_text(x+240,y+128,"在左侧食谱列表中装配食谱")
		}
	}
}