// 绘制半透明遮罩
panel_anim_step(id)                 // 自己的淡入淡出（关闭播完自己销毁）
if (!instance_exists(id)) { exit }
var _a = ui_anim_alpha(id)   // 跟着背包面板一起淡（文字不吃 image_alpha）
draw_set_alpha(0.5 * _a)
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(_a);
draw_self()

draw_self()
// 绘制标题
draw_set_color(c_white)
draw_set_font(font_yuan); // 使用菜单字体
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x, y - 165, "宝石信息编辑");
// 绘制文字
draw_text(x, y - 105, "星级");
for(var i = 0 ; i< 1 ; i++){
	draw_sprite_ext(spr_package_number_bg, 0, x, y-70+80*i, 0.75, 0.75, 0, c_white, _a)
}
if not info_got{
	var card_id = global.save_data.unlocked_gems[target_card_index].id
	target_current_info = get_gem_level(card_id)
	target_max_info = get_gem_max_level(card_id)
	view_max_shape = global.save_data.unlocked_items.max_gem_level
	info_got = 1
}
draw_set_font(font_number);
draw_text(x,y-70,$"{target_current_info}/{target_max_info}")
draw_set_font(font_yuan);
draw_set_alpha(1)