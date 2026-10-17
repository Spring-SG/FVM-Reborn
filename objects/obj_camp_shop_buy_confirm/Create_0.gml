// obj_quit_confirm - Create Event
bg = spr_camp_shop_buy_confirm_menu;
width = sprite_get_width(bg);
height = sprite_get_height(bg);

// 按钮定义
buttons = [
    [0, spr_camp_shop_buy_confirm_btn, 200, 90,120],
    [300, spr_camp_shop_buy_confirm_close_btn, 70, 70,-212]
];

selected_button = -1;
target_shape = 1
banding_buy_btn = noone

// 定位到屏幕中心
x = room_width / 2;
y = room_height / 2;