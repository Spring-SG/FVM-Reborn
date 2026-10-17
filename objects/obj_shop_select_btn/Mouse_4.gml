if not obj_shop_bg.is_submenu_opened{

var _pg_changed = (obj_shop_bg.shop_button_select != button_index)   // 点当前页签不重播淡入
obj_shop_bg.shop_button_select = button_index
obj_shop_bg.current_page = 1
with obj_shop_bg{
		if _pg_changed pg_t = ui_anim_on(1) ? 0 : -1   // 页签切换：整页淡入（动效等级 <1 直接终态）
		shop_list_recharge()
	}
global.audio.play(snd_button,0,0)
}