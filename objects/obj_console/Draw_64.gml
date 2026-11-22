// ═══════════════════════════════════════════════════════════════════════════
// 控制台面板（Draw GUI）：背板 + 标题 + 输出区 + 输入行
// ═══════════════════════════════════════════════════════════════════════════
if (!console_open) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _pad   = 24;
var _x0    = _pad;
var _y0    = _pad;
var _w     = _gw - _pad * 2;
var _h     = round(_gh * 0.62);
var _x1    = _x0 + _w;
var _y1    = _y0 + _h;

// ── 背板 ──
draw_set_alpha(0.89);
draw_set_color(make_color_rgb(10, 14, 20));
draw_rectangle(_x0, _y0, _x1, _y1, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(70, 120, 160));
draw_rectangle(_x0, _y0, _x1, _y1, true);

// ── 标题 ──
draw_set_font(font_hei);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(150, 220, 255));
draw_text(_x0 + 14, _y0 + 8, "控制台  ·  help 查看指令  ·  ~ / Esc 关闭  ·  ↑↓ 历史  ·  滚轮翻页");
if (!global.console_enabled) {
	draw_set_color(make_color_rgb(255, 140, 140));
	draw_text(_x0 + _w - 260, _y0 + 8, "已在 config.ini 中禁用");
}
draw_set_color(make_color_rgb(60, 90, 120));
draw_line_width(_x0 + 12, _y0 + 36, _x1 - 12, _y0 + 36, 1);

// ── 输出区 ──
var _line_h   = 22;
var _input_h  = 34;
var _area_top = _y0 + 44;
var _area_bot = _y1 - _input_h - 10;
var _visible  = max(1, floor((_area_bot - _area_top) / _line_h));

var _total = array_length(console_log);
console_scroll = clamp(console_scroll, 0, max(0, _total - _visible));

var _end   = _total - console_scroll;
var _start = max(0, _end - _visible);

for (var i = _start; i < _end; i++) {
	var _ly  = _area_top + (i - _start) * _line_h;
	var _txt = console_log[i];
	// 命令回显（> 开头）用绿色，错误（[错误] 开头）用红色，其余灰色
	if (string_copy(_txt, 1, 1) == ">") {
		draw_set_color(make_color_rgb(130, 235, 175));
	} else if (string_copy(_txt, 1, 7) == "[错误]") {
		draw_set_color(make_color_rgb(255, 150, 150));
	} else {
		draw_set_color(make_color_rgb(205, 225, 215));
	}
	draw_text(_x0 + 14, _ly, _txt);
}

// ── 输入行 ──
draw_set_color(make_color_rgb(26, 36, 48));
draw_rectangle(_x0 + 8, _area_bot + 4, _x1 - 8, _area_bot + 4 + _input_h - 4, false);
draw_set_color(make_color_rgb(60, 90, 120));
draw_rectangle(_x0 + 8, _area_bot + 4, _x1 - 8, _area_bot + 4 + _input_h - 4, true);

var _caret = ((floor(console_caret / 30) mod 2) == 0) ? "_" : "";
draw_set_color(make_color_rgb(140, 240, 190));
draw_text(_x0 + 16, _area_bot + 11, "> " + console_input + _caret);

// ── 状态行 ──
draw_set_color(make_color_rgb(110, 150, 180));
draw_text(_x1 - 240, _area_bot + 11, "debug = " + string(global.debug));

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);