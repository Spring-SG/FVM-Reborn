// obj_quit_confirm - Create Event
bg = spr_battle_escape_menu;
width = sprite_get_width(bg);
height = sprite_get_height(bg);

// 按钮定义
buttons = [
    [-80, "确定", 110, 40],
    [80, "取消", 110, 40]
];

selected_button = -1;

banding_buy_btn = noone
buy_goods_name = ""   // 购买按钮可能先被 shop_list_recharge() 销毁，名字先存一份

// 定位到屏幕中心
x = room_width / 2;
y = room_height / 2;

// 三级菜单淡入淡出（等级 1 起；子对象跟着一起淡）
panel_anim_init(id, 0.18, 0.14, 0, 3)
panel_anim_kids(id, [])

// 弹窗弹出/回缩：GuiStack pop_anim_*（0.20s，ease-out back），关闭时反向缩回
pop_anim_init(id, [])
