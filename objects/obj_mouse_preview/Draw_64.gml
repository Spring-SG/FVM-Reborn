// 悬停判定：直接按「裁剪框」这片矩形算，和真正画出来的范围一致。
// ⚠️ 不要用引擎自带的 Mouse Enter / Mouse Leave（obj_mouse_preview 里已删掉）：
//    那两个事件按实例 bbox 判定，而精灵现在不是画在实例坐标上的（按内容包围盒居中贴底），
//    判定区会跑到贴图上方的空位，tooltip 在对不上的地方冒出来。
// 裁剪框：水平 [x - w/2, x + w/2]，竖直 [y - h, y]（底边贴住实例 y，见 Draw_0）
var _bx0 = x - clip_box_w * 0.5;
var _by0 = y - clip_box_h;
var _bx1 = x + clip_box_w * 0.5;
var _by1 = y;
on_click = point_in_rectangle(mouse_x, mouse_y, _bx0, _by0, _bx1, _by1)

if on_click{
	var _tt_left = (x >= 600);
		draw_set_font(font_yuan);
		tooltip_set(_tt_left ? mouse_x - 15 : mouse_x + 15, mouse_y - 25, tooltip_text, _tt_left ? -1 : 1);
}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();
