panel_anim_step(id)                 // 推进进出场（关闭播完自己销毁）
if (!instance_exists(id)) { exit }

var _a = ui_anim_alpha(id)

// 背景压暗（不参与滑动录制，滑的只有面板本身）
draw_set_alpha(0.55 * _a)
draw_rectangle_colour(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)

panel_anim_begin(id)

var _r = 18
// 面板底
draw_roundrect_colour_ext(px1, py1, px2, py2, _r, _r,
	make_colour_rgb(16, 68, 116), make_colour_rgb(3, 22, 46), false)
// 外描边
draw_set_colour(make_colour_rgb(58, 150, 214))
draw_roundrect_ext(px1 + 1, py1 + 1, px2 - 1, py2 - 1, _r - 1, _r - 1, true)
// 内侧奶油细线
draw_set_alpha(0.30)
draw_set_colour(make_colour_rgb(249, 242, 198))
draw_roundrect_ext(px1 + 8, py1 + 8, px2 - 8, py2 - 8, _r - 5, _r - 5, true)
draw_set_alpha(1)
// 顶部高光
draw_set_alpha(0.06)
draw_roundrect_colour_ext(px1 + 3, py1 + 3, px2 - 3, py1 + 104, _r - 2, _r - 2, c_white, c_white, false)
draw_set_alpha(1)

draw_set_font(font_yuan)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

// ── 标题 ──
var _ttl = "致谢"
var _tsc = 2.0
var _tw  = string_width(_ttl) * _tsc
var _th  = string_height(_ttl) * _tsc
draw_set_colour(make_colour_rgb(249, 242, 198))
draw_text_transformed(x - _tw * 0.5, py1 + 78 - _th * 0.5, _ttl, _tsc, _tsc, 0)
// 标题两侧的横线
draw_set_alpha(0.55)
draw_set_colour(make_colour_rgb(58, 150, 214))
draw_rectangle(px1 + 60, py1 + 76, x - _tw * 0.5 - 34, py1 + 78, false)
draw_rectangle(x + _tw * 0.5 + 34, py1 + 76, px2 - 60, py1 + 78, false)
draw_set_alpha(1)

// ── 副标题 ──
var _sub = "感谢每一位参与制作、提供素材与慷慨支持本作的人"
var _ssc = 0.95
var _sw  = string_width(_sub) * _ssc
draw_set_alpha(0.85)
draw_set_colour(make_colour_rgb(176, 208, 236))
draw_text_transformed(x - _sw * 0.5, py1 + 130, _sub, _ssc, _ssc, 0)
draw_set_alpha(1)

// ── 名单 ──
var _lsc = 1.06
for (var i = 0; i < array_length(credits); i++) {
	var _row = credits[i]
	var _cy  = row_y0 + i * row_dy
	var _ty  = _cy - string_height(_row[0]) * _lsc * 0.5
	// 行间分隔线（第一行不加）
	if (i > 0) {
		draw_set_alpha(0.10)
		draw_set_colour(c_white)
		draw_rectangle(px1 + 60, _cy - row_dy * 0.5, px2 - 60, _cy - row_dy * 0.5 + 1, false)
		draw_set_alpha(1)
	}
	draw_set_colour(make_colour_rgb(249, 242, 198))
	draw_text_transformed(px1 + 60, _ty, _row[0], _lsc, _lsc, 0)
	// 占位内容（待填写）画成灰字，和真实名单区分开
	if (_row[1] == "待填写") {
		draw_set_colour(make_colour_rgb(168, 180, 196))
	}
	else {
		draw_set_colour(c_white)
	}
	draw_text_transformed(px1 + 300, _ty, _row[1], _lsc, _lsc, 0)
}

// ── 关闭按钮 ──
var _cs  = 1 + 0.04 * close_s
var _chw = close_w * 0.5 * _cs
var _chh = close_h * 0.5 * _cs
var _cx  = (close_x1 + close_x2) * 0.5
var _ccy = (close_y1 + close_y2) * 0.5
var _bx1 = _cx - _chw
var _by1 = _ccy - _chh
var _bx2 = _cx + _chw
var _by2 = _ccy + _chh
var _br  = _chh * 0.62

draw_set_alpha(0.32)
draw_roundrect_colour_ext(_bx1 + 1, _by1 + 3, _bx2 + 1, _by2 + 3, _br, _br, c_black, c_black, false)
draw_set_alpha(1)
draw_roundrect_colour_ext(_bx1, _by1, _bx2, _by2, _br, _br,
	merge_colour(make_colour_rgb(60, 143, 203), make_colour_rgb(124, 198, 245), close_s),
	merge_colour(make_colour_rgb(14, 75, 125),  make_colour_rgb(30, 108, 166),  close_s), false)
draw_set_colour(merge_colour(make_colour_rgb(249, 242, 198), c_white, close_s))
draw_roundrect_ext(_bx1 + 1, _by1 + 1, _bx2 - 1, _by2 - 1, _br - 1, _br - 1, true)

var _ct  = "关闭"
var _csc = 1.1
var _ctw = string_width(_ct) * _csc
var _cth = string_height(_ct) * _csc
draw_set_colour(c_white)
draw_text_transformed(_cx - _ctw * 0.5, _ccy - _cth * 0.5, _ct, _csc, _csc, 0)

// ── 底部提示 ──
draw_set_alpha(0.5)
draw_set_colour(make_colour_rgb(176, 208, 236))
draw_text_transformed(px1 + 60, close_y1 + 12, "按 ESC 也可以关闭本页", 0.85, 0.85, 0)
draw_set_alpha(1)

draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

panel_anim_end_slide(id, 260)