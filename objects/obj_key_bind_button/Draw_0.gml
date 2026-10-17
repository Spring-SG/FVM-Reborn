// 绘制按钮背景
var _x1 = x - sprite_width/2;
var _y1 = y - sprite_height/2;
var _x2 = x + sprite_width/2;
var _y2 = y + sprite_height/2;

if (is_waiting) {
    image_index = 0
} else if (point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2)) {
    image_index = 1
} else {
    image_index = 2
}

//draw_rectangle(_x1, _y1, _x2, _y2, false);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_self()
ui_anim_text_alpha(id);
draw_set_font(font_hei)
draw_text(x, y, display_text);
draw_set_font(font_yuan)
draw_text(x-600, y, key_name);
draw_set_alpha(1);        // 复位：别把透明度漏给下面的悬停提示

// 绘制悬停提示
if (point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2) && tooltip_text != "") {
	tooltip_set(mouse_x + 15, mouse_y + 20, tooltip_text, 1, 0.8);
	}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();
