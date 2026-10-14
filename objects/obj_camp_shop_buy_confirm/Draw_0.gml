// obj_quit_confirm - Draw Event

// 绘制半透明背景
if not instance_exists(obj_pause_menu){
	draw_set_alpha(0.5);
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}

// 绘制背景
draw_sprite_ext(bg, 0, x, y, 1.8, 1.8, 0, c_white, 1);

// 绘制提示文本
draw_set_font(font_yuan);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black)
//draw_text(x, y - 112, "购买确认")
draw_text_transformed(x, y - 90, "确定购买"+banding_buy_btn.goods_name+"吗？",1.2,1.2,0);
draw_set_halign(fa_left);
draw_text_transformed(x-240, y - 10, "消耗货币",1.2,1.2,0);
draw_set_colour(c_white)
draw_sprite_ext(spr_camp_shop_buy_confirm_coin_display,0,x+80,y-10,1.8,1.8,0,c_white,1)
draw_sprite_ext(spr_craft_material,get_material_info(banding_buy_btn.coin_type).icon,x-70,y-10,0.9,0.9,0,c_white,1)
draw_text_transformed(x-10, y - 10, string(banding_buy_btn.cost),1.2,1.2,0);

// 绘制按钮
for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var btn_x = x + btn[0];
    var btn_y = y + btn[4];
    
    // 确定按钮状态
    var frame = 0; // 普通状态
    if (selected_button == i) {
        frame = (mouse_check_button_pressed(mb_left)) ? 0 : 1;
    }
    
    draw_sprite_ext(btn[1],  frame,  btn_x,  btn_y, 1.8, 1.8,  0,  c_white,  1);
}