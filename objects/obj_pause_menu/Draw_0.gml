// obj_pause_menu - Draw Event
// 绘制半透明背景
draw_set_alpha(0.5);
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// 绘制菜单背景
//var bg = spr_pause_menu;
//draw_sprite_ext(bg, 0, menu_x, menu_y, 1, 1, 0, c_white, 1);
draw_self()

// 绘制标题
draw_set_color(c_white)
draw_set_font(font_yuan); // 使用菜单字体
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(menu_x, menu_y - 138, "游戏暂停");

// 绘制关卡信息
//var level_time = "通关时间: " + string_format(global.level_time, 1, 2) + "秒";
//var level_name = "当前关卡: " + global.level_name;
draw_set_color(c_black)
draw_text(menu_x, menu_y - 65, global.level_data.name);
var minute = floor(obj_battle.battle_time/3600)
var second = floor(obj_battle.battle_time/60 - minute * 60)
draw_text(menu_x, menu_y - 35, "耗时："+string(minute)+"分"+string(second)+"秒");
draw_text(menu_x, menu_y - 5, "卡片损失："+string(obj_task_manager.card_loss));
draw_set_color(c_white)
// 绘制按钮
for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var btn_x = menu_x + btn[0];
    var btn_y = menu_y + 120 + btn[4];
    
    // 确定按钮状态
    var frame = button_normal;
    if (selected_button == i) {
        frame = (mouse_check_button_pressed(mb_left)) ? button_pressed : button_hover;
    }
    
    // 绘制按钮
    draw_sprite_ext(spr_common_button,  frame,  btn_x,  btn_y, 0.75, 0.75,  0,  c_white,  1);
    
    // 绘制按钮文本
    draw_set_font(font_yuan);
    draw_text(btn_x, btn_y, btn[1]);
}