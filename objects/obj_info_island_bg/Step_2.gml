obj_player_info_ui.menu_type = 4
obj_world_map_button.world_map = 2

// ---- 二级菜单过渡推进 ----
// 动效等级 < 1：不滑不淡，直接终态（子对象回基准位置、alpha 1）；正在关闭就立刻销毁
if (!ui_anim_on(1)){
	pnl_o = 1
	pnl_t = 0
	for (var _gi = 0; _gi < array_length(anim_kids); _gi++){
		var _gc = anim_kids[_gi][0]
		if (instance_exists(_gc)){
			_gc.x = _gc.anim_base_x
			_gc.image_alpha = 1
		}
	}
	with (obj_info_island_edit_menu)            { image_alpha = 1 }
	with (obj_info_island_edit_menu_btn)        { image_alpha = 1 }
	with (obj_info_island_card_edit_select_btn) { image_alpha = 1 }
	if (pnl_closing) instance_destroy()
	exit
}
// ---- 页签切换：页面不动，瞬时换页 + 新内容淡入（计时在 Draw_0 顶部，这里只声明状态）----
if (!variable_instance_exists(id, "tab_fade")) {
	tab_fade = 1; tab_fade_t = -1
	tab_shown = info_button_select
}

panel_anim_step(id, false)   // 统一时间线：推进 pnl_o，关闭播完自己销毁（mode 3 之外的位移归本对象）

var _shift = (1 - pnl_o) * anim_slide
for (var _i = 0; _i < array_length(anim_kids); _i++){
    var _c = anim_kids[_i][0]
    if (instance_exists(_c)){
        _c.x = _c.anim_base_x + anim_kids[_i][1] * _shift
        _c.pnl_po = pnl_o          // 放进统一进度：子对象自己 ui_anim_alpha() 就能读到
        _c.image_alpha = pnl_o
    }
}
// 强化子菜单是独立实例（不在 anim_kids 里），也要跟着一起淡，否则它的面板/文字会单独留在屏幕上
with (obj_info_island_edit_menu) { pnl_po = other.pnl_o; image_alpha = other.pnl_o }
with (obj_info_island_edit_menu_btn) { pnl_po = other.pnl_o; image_alpha = other.pnl_o }
with (obj_info_island_card_edit_select_btn) { pnl_po = other.pnl_o; image_alpha = other.pnl_o }

