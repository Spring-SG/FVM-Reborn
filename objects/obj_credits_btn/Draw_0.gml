if (!global.menu_screen) { exit }   // 只在玩家信息菜单里画

var _s  = 1 + 0.05 * hover          // 悬停时轻微放大
var _hw = bw_half * _s
var _hh = bh_half * _s
var _x1 = x - _hw
var _y1 = y - _hh
var _x2 = x + _hw
var _y2 = y + _hh
var _r  = _hh * 0.62
var _hv = hover * 0.45              // 悬停提亮幅度（拉满会发白，只取一半）
var _gl = hover * 0.6               // 悬停外发光强度

draw_set_font(font_yuan)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

// 悬停外发光：细一圈白边，比整体提亮更像「被探亮」
if (_gl > 0.02) {
	draw_set_alpha(0.30 * _gl)
	draw_set_colour(c_white)
	draw_roundrect_ext(_x1 - 2, _y1 - 2, _x2 + 2, _y2 + 2, _r + 2, _r + 2, true)
}

// 投影
draw_set_alpha(0.32)
draw_roundrect_colour_ext(_x1 + 1, _y1 + 3, _x2 + 1, _y2 + 3, _r, _r, c_black, c_black, false)
draw_set_alpha(1)

// 主体：上亮下暗的蓝（和图标按钮同一色系）
draw_roundrect_colour_ext(_x1, _y1, _x2, _y2, _r, _r,
	merge_colour(make_colour_rgb(60, 143, 203), make_colour_rgb(124, 198, 245), _hv),
	merge_colour(make_colour_rgb(14, 75, 125),  make_colour_rgb(30, 108, 166),  _hv), false)

// 奶油色描边 + 顶部高光
draw_set_colour(merge_colour(make_colour_rgb(249, 242, 198), c_white, _hv))
draw_roundrect_ext(_x1 + 1, _y1 + 1, _x2 - 1, _y2 - 1, _r - 1, _r - 1, true)
draw_set_alpha(0.10 + 0.04 * hover)
draw_roundrect_colour_ext(_x1 + 4, _y1 + 3, _x2 - 4, _y1 + _hh * 0.52, _r - 3, _r - 3, c_white, c_white, false)
draw_set_alpha(1)

// 文字：超宽就等比缩到框内
var _txt = "致谢"
var _tw  = string_width(_txt)
var _th  = string_height(_txt)
var _sc  = min(1.15, (bw - 12) / max(_tw, 1))
draw_set_colour(c_white)
draw_text_transformed(x - _tw * _sc * 0.5, y - _th * _sc * 0.5 + 1, _txt, _sc, _sc, 0)

// 悬停提示（走全局 tooltip，同一帧只会显示最后 set 的那一个）
if (hover > 0.55) {
	tooltip_set(x + _hw + 10, y - 10, "致谢\n看看都是谁做了这款游戏", 1)
}
tooltip_draw()

draw_set_alpha(1)
draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)