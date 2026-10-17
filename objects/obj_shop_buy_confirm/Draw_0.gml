// obj_quit_confirm - Draw Event
panel_anim_step(id)
if (!instance_exists(id)) { exit }
var _a = ui_anim_alpha(id)   // 跟着商城面板一起淡（文字不吃 image_alpha）

// 绘制半透明背景
if not instance_exists(obj_pause_menu){
	draw_set_alpha(0.5 * _a);
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
}
draw_set_alpha(_a);

// 绘制背景
draw_sprite_ext(bg, 0, x, y, 1.5, 1.5, 0, c_white, _a);

// 绘制提示文本
draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white)
draw_text(x, y - 112, "购买确认")
draw_text(x, y - 10, "确定购买"+banding_buy_btn.goods_name+"吗？");
if obj_shop_bg.shop_button_select == 5{
	draw_set_color(c_yellow)
	draw_text(x, y + 15, "在左上角的编辑菜单中切换角色时装。");
	draw_set_color(c_white)
}
if obj_shop_bg.shop_button_select == 4{
	draw_set_color(c_yellow)
	draw_text(x, y + 15, "你需要在背包中切换卡片时装。");
	draw_set_color(c_white)
}

// 绘制按钮
for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var btn_x = x + btn[0];
    var btn_y = y + 70;
    
    // 确定按钮状态
    var frame = 0; // 普通状态
    if (selected_button == i) {
        frame = (mouse_check_button_pressed(mb_left)) ? 2 : 1;
    }
    
    draw_sprite_ext(spr_common_button,  frame,  btn_x,  btn_y, 0.75, 0.75,  0,  c_white,  _a);   // 跟着面板淡出
    draw_set_font(font_yuan);
    draw_text(btn_x, btn_y, btn[1]);
}
draw_set_alpha(1)