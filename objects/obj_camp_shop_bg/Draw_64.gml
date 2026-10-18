/// 营地商店商品悬浮提示框：同商城，集中判一次、画一次
if (is_submenu_opened) { tooltip_draw(); exit; }

// 命中区 = 商品图标那半边，不含右侧名称/价格与购买按钮：
//   卡片贴图 spr_camp_shop_goods_bg 208×98、原点 (104,49)、按 1.8 倍画在 (x-590+380*i, y-130+190*j)
//   图标画在卡片中心 + (-105, +25)，与商城图标框同比例 → 取图标中心离卡片中心 (-105, 0)、半边 (66, 79)
//   购买按钮建在同一格中心的 (+45, +40) 处 → 反推卡片中心 = (x-45, y-40)
var _tt_text = "";
with (obj_camp_shop_buy_btn) {
var _cx = x - 150;
var _cy = y - 40;
if (!is_disabled && tooltip_text != ""
 && point_in_rectangle(mouse_x, mouse_y, _cx - 66, _cy - 79, _cx + 66, _cy + 79)) {
_tt_text = tooltip_text;
}
}
if (_tt_text != "") {
var _gx = device_mouse_x_to_gui(0);
var _gy = device_mouse_y_to_gui(0);
var _tt_left = (_gx >= display_get_gui_width() * 0.5);
draw_set_font(font_yuan);
tooltip_set(_tt_left ? _gx - 15 : _gx + 15, _gy - 25, _tt_text, _tt_left ? -1 : 1);
}
tooltip_draw();
