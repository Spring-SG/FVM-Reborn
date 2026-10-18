/// 商城商品悬浮提示框：唯一命中项由商城背景统一判定并绘制。
/// 若由每个 obj_shop_buy_btn 在各自的 Draw_64 里判定，同帧多个实例命中会同时绘制且互不收束，
/// 表现为整屏提示框。
if (pnl_o < 0.999) { tooltip_draw(); exit; }// 面板进场/退场期间不弹
if (is_submenu_opened) { tooltip_draw(); exit; }

// 命中区 = 商品图标的方框，不含右侧名称/价格面板与购买按钮：
//   卡片贴图 spr_shop_goods_bg 226×89、原点 (113,44)、按 1.8 倍画在 (x-618+411*i, y-190+165*j)
//   卡片里图标方框占 art 的 x 5..84 / y 4..83（80×80，左上角那块）→ 中心离卡片中心 (-68.5, -0.5)
//   1.8 倍后图标中心离卡片中心 (-123, -1)、半边 72
//   购买按钮建在同一格中心的 (+77, +60) 处 → 反推卡片中心 = (x-77, y-60)
var _tt_text = "";
with (obj_shop_buy_btn) {
var _cx = x - 200;
var _cy = y - 61;
if (!is_disabled && tooltip_text != ""
 && point_in_rectangle(mouse_x, mouse_y, _cx - 72, _cy - 72, _cx + 72, _cy + 72)) {
_tt_text = tooltip_text;
}
}
if (_tt_text != "") {
// 锚点必须用 GUI 坐标：Draw GUI 画在 GUI 空间，而 mouse_x/mouse_y 是房间坐标；
// 窗口带缩放时两者偏差随位置增大。
var _gx = device_mouse_x_to_gui(0);
var _gy = device_mouse_y_to_gui(0);
var _tt_left = (_gx >= display_get_gui_width() * 0.5);
draw_set_font(font_yuan);
tooltip_set(_tt_left ? _gx - 15 : _gx + 15, _gy - 25, _tt_text, _tt_left ? -1 : 1);
}
tooltip_draw();
