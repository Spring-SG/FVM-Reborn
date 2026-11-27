panel_anim_step(id)                 // 推进进出场（关闭播完自己销毁）
if (!instance_exists(id)) { exit }

var _a = ui_anim_alpha(id)

// ── 唯一的一层黑色半透明遮罩（不参与录制，滑入的只有文字）──
draw_set_alpha(0.70 * _a)
draw_rectangle_colour(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false)
draw_set_alpha(1)

panel_anim_begin(id)

draw_set_font(font_yuan)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

// ── 标题 + 下方短线 ──
var _ttl = "创作者名单"
var _tsc = 1
var _tw  = string_width(_ttl) * _tsc
var _th  = string_height(_ttl) * _tsc
draw_set_colour(make_colour_rgb(249, 242, 198))
draw_text_transformed(cx - _tw * 0.5, title_y - _th * 0.5, _ttl, _tsc, _tsc, 0)
draw_set_alpha(0.45)
draw_set_colour(make_colour_rgb(249, 242, 198))
draw_rectangle(cx - 70, title_y + _th * 0.5 + 8, cx + 70, title_y + _th * 0.5 + 10, false)
draw_set_alpha(1)

// ── 副标题 ──
var _sub = "除爱发电支持者外，创作者名称均为B站ID"
var _ssc = 1.0
var _sw  = string_width(_sub) * _ssc
draw_set_alpha(1)
draw_set_colour(make_colour_rgb(186, 214, 240))
draw_text_transformed(cx - _sw * 0.5, sub_y, _sub, _ssc, _ssc, 0)
draw_set_alpha(1)

// ── 名单：标签右对齐（贴着中线左侧），姓名左对齐 ──
var _lsc = 1
for (var i = 0; i < array_length(credits); i++) {
	var _row = credits[i]
	var _cy  = row_y0 + i * row_dy
	var _ty  = _cy - string_height(_row[0]) * _lsc * 0.5

	var _lw = string_width(_row[0]) * _lsc
	draw_set_colour(make_colour_rgb(249, 242, 198))
	draw_text_transformed(label_x - _lw, _ty, _row[0], _lsc, _lsc, 0)

	// 占位内容（待填写）画成灰字，和真实名单区分开
	if (_row[1] == "待填写") {
		draw_set_colour(make_colour_rgb(170, 182, 198))
	}
	else {
		draw_set_colour(c_white)
	}
	draw_text_transformed(name_x, _ty, _row[1], _lsc, _lsc, 0)
}

// ── 底部 5 个链接按钮（spr_common_button：0 = 普通 / 1 = 悬停 / 2 = 按下）──
for (var i = 0; i < array_length(links); i++) {
	var _bx1 = btn_x0 + i * (btn_w + btn_gap)
	var _bcx = _bx1 + btn_w * 0.5
	var _bf  = 0
	if (btn_hover == i) { _bf = mouse_check_button(mb_left) ? 2 : 1 }
	draw_sprite_ext(spr_common_button, _bf, _bcx, btn_y, btn_sc, btn_sc, 0, c_white, 1)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_colour(c_white)
	draw_text(_bcx, btn_y, links[i][0])
}
draw_set_halign(fa_left)
draw_set_valign(fa_top)

// ── 底部提示 ──
var _hint = "ESC或鼠标右键退出"
var _hsc  = 1
var _hw   = string_width(_hint) * _hsc
draw_set_alpha(1)
draw_set_colour(make_colour_rgb(186, 214, 240))
draw_text_transformed(cx - _hw * 0.5, hint_y, _hint, _hsc, _hsc, 0)
draw_set_alpha(1)

draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

panel_anim_end_slide(id, 260)

// 悬停提示：必须在录制贴回之后再画，否则会跟着文字一起滑动
// （目前只有「爱发电」配了提示；放在按钮行下方，避免压到上面那行名单）
if (btn_hover >= 0 && links[btn_hover][2] != "") {
	draw_set_font(font_yuan)
	var _hx = btn_x0 + btn_hover * (btn_w + btn_gap) + btn_w * 0.5
	tooltip_set(_hx, btn_y + btn_h * 0.5 + 16, links[btn_hover][2], -1)
}
tooltip_draw()
