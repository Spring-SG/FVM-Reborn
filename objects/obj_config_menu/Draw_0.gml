if global.menu_screen{
	draw_set_alpha(0.5);
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}
draw_self()
draw_set_font(font_yuan)
draw_set_color(c_white)
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_ext_transformed(x,y-345,"游戏设置",0,900,2,2,0)

switch (button_select) {
    case 2: // 画面设置
        // 绘制设置标签
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_text(x - 380, y - 180, "屏幕震动");
		draw_text(x - 380, y - 100, "闪烁效果");
		draw_text(x - 380, y - 20, "全屏");
		draw_text(x - 380, y + 60, "纹理过滤");
		draw_text(x - 380, y + 140, "无边框窗口");
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	    break;
	case 3:
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_text(x - 380, y - 180, "卡片血条");
		draw_text(x - 380, y - 100, "敌人血条");
		draw_text(x - 380, y - 20, "难度");
		draw_text(x - 380, y + 60, "失去焦点时暂停");
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		break
    
    // 可以添加其他设置页面
	case 0:
		// 绘制音频设置标签
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(c_white);

		// 音乐标签
		draw_text_ext_transformed(x - 430, y - 155, "音乐",0,900,1,1,0);
		draw_text_ext_transformed(x + 200, y - 165, string(round(global.music_volume * 100)) + "%", 0, 900, 1.5, 1.5, 0);

		// 音效标签
		draw_text_ext_transformed(x - 430, y - 75, "音效",0,900,1,1,0);
		draw_text_ext_transformed(x + 200, y - 85, string(round(global.sound_volume * 100)) + "%", 0, 900, 1.5, 1.5, 0);

		// 绘制进度条背景
		var bar_height = 20;
		var bar_min_x = x - 320;
		var bar_max_x = x + 80;

		// 音乐进度条
		draw_set_color(merge_color(c_blue,c_black,0.5));
		draw_roundrect(bar_min_x, y - 150, bar_max_x, y - 130, false);
		draw_set_color(merge_color(c_aqua,c_white,0.3));
		draw_roundrect(bar_min_x, y - 150, bar_min_x + (bar_max_x - bar_min_x) * global.music_volume, y - 130, false);

		// 音效进度条
		draw_set_color(merge_color(c_blue,c_black,0.5));
		draw_roundrect(bar_min_x, y - 70, bar_max_x, y - 50, false);
		draw_set_color(merge_color(c_aqua,c_white,0.3));
		draw_roundrect(bar_min_x, y - 70, bar_min_x + (bar_max_x - bar_min_x) * global.sound_volume, y - 50, false);
		break;
	case 1:
		// 绘制标签
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(c_white);
		draw_text(x - 350, y - 170, "替换放置");
		draw_text(x + 50, y - 170, "快速放置");
		draw_text(x - 420, y - 115, "快捷键设置:");

		// 绘制当前页数
		draw_set_halign(fa_center);
		draw_text(x, y + 300, "第" + string(keybind_page + 1) + "页/共" + string(total_keybind_pages) + "页");
		break;
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);