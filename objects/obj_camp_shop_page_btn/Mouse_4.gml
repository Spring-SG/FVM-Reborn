if not obj_camp_shop_bg.is_submenu_opened{
	var _prev_page = obj_camp_shop_bg.current_page
	var _is_next = (btn_type == "next")
	if btn_type == "prev"{
		if obj_camp_shop_bg.current_page > 1{
			obj_camp_shop_bg.current_page --
		}
	}
	else if btn_type == "next"{
		if obj_camp_shop_bg.current_page < obj_camp_shop_bg.current_max_page{
			obj_camp_shop_bg.current_page ++
		}
	}
	global.audio.play(snd_button,0,0)
with obj_camp_shop_bg{
// 页码确实变化时才播翻页动画（Crossfade + Stagger，与商城同参数）
if (current_page != _prev_page) {
pg_dir    = _is_next ? 1 : -1
pg_switch = true
pg_t      = ui_anim_on(2) ? 0 : -1     // 动效等级 <2 直接终态
}
shop_list_recharge()
}
}