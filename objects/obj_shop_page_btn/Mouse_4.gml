if not obj_shop_bg.is_submenu_opened{
var _pg_flip = false
if btn_type == "prev"{
if obj_shop_bg.current_page > 1{
obj_shop_bg.current_page --
_pg_flip = true
}
}
else if btn_type == "next"{
if obj_shop_bg.current_page < obj_shop_bg.current_max_page{
obj_shop_bg.current_page ++
_pg_flip = true
}
}
global.audio.play(snd_button,0,0)
// 方向必须在 with 之前取出：进入 with obj_shop_bg 后 btn_type 会解析到 bg 上（无此变量 → 报错）
var _pg_next = (btn_type == "next")
with obj_shop_bg{
shop_list_recharge()
if (_pg_flip) {
pg_dir = _pg_next ? 1 : -1    // 往后翻从右边滑入，往前翻从左边
pg_switch = true
				pg_t = ui_anim_on(2) ? 0 : -1 // 动效等级 <2 直接终态（翻页动画只在最高档生效）
}
}
}
