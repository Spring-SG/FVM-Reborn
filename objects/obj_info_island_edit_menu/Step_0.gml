// 二级菜单弹出（scale in）：绕面板中心由小到大弹开，与 obj_info_island_edit_menu/Create_0.gml 参数一致
// 子对象位置按同一比例向中心收放并同步缩放；文字在 Draw_0 里按 pop_s 缩放
// 曲线 ease-out back（c1 = 1.70158）：0.84 → 1，终点轻微过冲后回落
if (!variable_instance_exists(id, "pop_t")) {
	pop_t = 0; pop_dur = 0.20; pop_from = 0.84
	pop_s = 1; pop_p = 1; pop_base_s = image_xscale
}
if (pop_p >= 1) { exit }

var _s = 1
if (ui_anim_on(1)) {
	pop_t += ui_anim_dt()
	var _p = clamp(pop_t / max(pop_dur, 0.0001), 0, 1)
	var _c1 = 1.70158
	var _e = 1 + (_c1 + 1) * power(_p - 1, 3) + _c1 * power(_p - 1, 2)
	_s = lerp(pop_from, 1, _e)
	if (_p >= 1) { pop_p = 1 }     // 播完收工，之后不再写子对象，免得抹掉它们自己的逻辑
} else {
	pop_p = 1                       // 动效等级 0：直接终态
}
pop_s = _s

image_xscale = pop_base_s * _s
image_yscale = pop_base_s * _s

var _mx = x;
var _my = y;
with (obj_info_island_card_edit_select_btn) {
	if (variable_instance_exists(id, "pop_bx")) {
		x = _mx + (pop_bx - _mx) * _s
		y = _my + (pop_by - _my) * _s
		image_xscale = pop_sx * _s
		image_yscale = pop_sx * _s
	}
}
with (obj_info_island_edit_menu_btn) {
	if (variable_instance_exists(id, "pop_bx")) {
		x = _mx + (pop_bx - _mx) * _s
		y = _my + (pop_by - _my) * _s
		image_xscale = pop_sx * _s
		image_yscale = pop_sx * _s
	}
}
