if global.menu_screen{
	draw_set_alpha(0.5);
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}
draw_self()
draw_sprite(spr_option_menu_bg_2,0,x,y+75)
draw_set_font(font_yuan)
draw_set_color(c_white)
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
//draw_text_ext_transformed(x,y-345,"游戏设置",0,900,2,2,0)

switch (button_select) {
    case 2: // 画面设置
        //绘制设置标签
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_middle);
		//draw_text(x - 380, y - 180, "屏幕震动");
		//draw_text(x - 380, y - 100, "闪烁效果");
		//draw_text(x - 380, y - 20, "全屏");
		//draw_text(x - 380, y + 60, "纹理过滤");
		//draw_text(x - 380, y + 140, "无边框窗口");
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_top);
		draw_sprite(spr_option_menu_text,1,x-360,y+30)
	    break;
	case 3:
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_middle);
		//draw_text(x - 380, y - 180, "卡片血条");
		//draw_text(x - 380, y - 100, "敌人血条");
		//draw_text(x - 380, y - 20, "难度");
		//draw_text(x - 380, y + 60, "失去焦点时暂停");
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_top);
		draw_sprite(spr_option_menu_text,2,x-120,y+30)
		draw_sprite_ext(spr_option_menu_difficulty,global.difficulty,x+15,y+72,0.2,0.2,0,c_white,1)
		break
    
    // 可以添加其他设置页面
	case 0:
		// 绘制音频设置标签
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(#9DCFEC);
		
		draw_sprite(spr_option_volume_bg,0,x,y-87)
		// 音乐标签
		//draw_text_ext_transformed(x - 430, y - 155, "音乐",0,900,1,1,0);
		draw_text_ext_transformed(x + 355, y - 148, string(round(global.music_volume * 100)) + "%", 0, 900, 1, 1, 0);

		// 音效标签
		//draw_text_ext_transformed(x - 430, y - 75, "音效",0,900,1,1,0);
		draw_text_ext_transformed(x + 355, y - 50, string(round(global.sound_volume * 100)) + "%", 0, 900, 1, 1, 0);

		// 绘制进度条背景
		var bar_height = 20;
		var bar_min_x = x - 280;
		var bar_max_x = x + 280;

		// 音乐进度条
		draw_sprite(spr_option_volume_bar,0,x+2,y-134)
		//draw_set_color(merge_color(c_blue,c_black,0.5));
		//draw_roundrect(bar_min_x, y - 150, bar_max_x, y - 120, false);
		draw_set_color(#17314C);
		draw_roundrect(bar_max_x, y - 150, bar_min_x + (bar_max_x - bar_min_x) * global.music_volume, y - 120, false);

		// 音效进度条
		draw_sprite(spr_option_volume_bar,0,x+2,y-37)
		//draw_set_color(merge_color(c_blue,c_black,0.5));
		//draw_roundrect(bar_min_x, y - 55, bar_max_x, y - 25, false);
		draw_set_color(#17314C);
		draw_roundrect(bar_max_x, y - 55, bar_min_x + (bar_max_x - bar_min_x) * global.sound_volume, y - 25, false);
		break;
	case 1:
		// 绘制标签
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(#9DCFEC);
		//draw_text(x - 350, y - 170, "替换放置");
		//draw_text(x + 50, y - 170, "快速放置");
		//draw_text(x - 420, y - 115, "快捷键设置:");
		draw_sprite(spr_option_menu_text,0,x,y+65)

		// 绘制当前页数
		draw_set_halign(fa_center);
		draw_text(x-65, y + 290, string(keybind_page + 1));
		draw_text(x+65, y + 290, string(total_keybind_pages));
		break;
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);