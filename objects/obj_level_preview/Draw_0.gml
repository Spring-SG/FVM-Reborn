draw_set_alpha(1)
draw_sprite(global.level_data.level_sprite,0,0,0)
draw_set_color(c_black)
draw_set_alpha(0.7)
draw_rectangle(0,0,room_width,room_height,0)
draw_set_alpha(1)
draw_set_font(font_yuan)
draw_set_colour(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_text(20,20,"右键点击或按ESC返回关卡")
draw_text(40,180,"普通敌人")
// BOSS 标签跟着 BOSS 行跑（普通敌人占几行，它就在第几行下面）
draw_text(40,boss_label_y,"BOSS")
// 页码：只有多页时才提示滚轮翻页
if (preview_pages > 1){
	draw_set_halign(fa_right)
	draw_text(room_width - 40, 20, "第 " + string(preview_page + 1) + "/" + string(preview_pages) + " 页　滚轮翻页")
	draw_set_halign(fa_left)
}
