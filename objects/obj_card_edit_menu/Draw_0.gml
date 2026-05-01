// 绘制半透明遮罩
draw_set_alpha(0.5)
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

draw_self()
// 绘制标题
draw_set_color(c_white)
draw_set_font(font_yuan); // 使用菜单字体
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y - 165, "卡片信息编辑");
// 绘制文字
draw_text(x, y - 105, "星级");
draw_text(x, y - 25, "转职");
draw_text(x, y + 55, "技能");
for(var i = 0 ; i< 3 ; i++){
	draw_sprite_ext(spr_package_number_bg,0,x,y-70+80*i,1.5,1.5,0,c_white,1)
}
if not info_got{
	var card_id = global.player_deck[| target_card_index*2];
	var length = array_length(global.save_data.unlocked_cards)
	var info_index = 0
	for (var i = 0;i < length;i++){
		if global.save_data.unlocked_cards[i].id == card_id{
			info_index = i
			break
		}
	}
	ds_map_add(target_current_info,"level",global.save_data.unlocked_cards[info_index].level)
	ds_map_add(target_current_info,"shape",global.save_data.unlocked_cards[info_index].shape)
	ds_map_add(target_current_info,"skill",global.save_data.unlocked_cards[info_index].skill)
	if array_length(get_card_attire_list(card_id)) > 0{
		var inst2 = instance_create_depth(x+520,y,depth-1,obj_card_attire_menu)
		inst2.target_card_id = card_id
	}
	info_got = 1
}
draw_text(x,y-70,string(target_current_info[? "level"]))
draw_text(x,y-70+80*1,string(target_current_info[? "shape"]))
draw_text(x,y-70+80*2,string(target_current_info[? "skill"]))