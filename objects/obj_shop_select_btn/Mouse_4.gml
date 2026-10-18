if not obj_shop_bg.is_submenu_opened{

var _pg_changed = (obj_shop_bg.shop_button_select != button_index)          // 点当前页签不重播
var _pg_dir     = (button_index > obj_shop_bg.shop_button_select) ? 1 : -1   // 往右的页签 -> 从右边滑入
obj_shop_bg.shop_button_select = button_index
obj_shop_bg.current_page = 1
with obj_shop_bg{
if _pg_changed {
pg_dir = _pg_dir                         // 方向感：新内容从它来的一侧滑进来
pg_switch = true                          // 先把上一帧内容拷成"旧内容"（交叉淡出的退场方）
pg_t = ui_anim_on(2) ? 0 : -1            // 动效等级 <2 直接终态（切标签页动画只在最高档生效）
}
shop_list_recharge()
}
global.audio.play(snd_button,0,0)
}
