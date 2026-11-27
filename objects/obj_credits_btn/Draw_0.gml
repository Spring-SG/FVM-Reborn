if (!global.menu_screen) { exit }   // 只在玩家信息菜单里画

// 按钮本体就是 spr_credits_btn（Step 里按悬停切第 0/1 帧）
draw_self()

// 悬停提示（走全局 tooltip，同一帧只会显示最后 set 的那一个）
if (hover) {
	draw_set_font(font_yuan)
	tooltip_set(x - dx + dw + 10, y - dy + dh * 0.5, "创作者名单", 1)
}
tooltip_draw()

draw_set_alpha(1)
draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
