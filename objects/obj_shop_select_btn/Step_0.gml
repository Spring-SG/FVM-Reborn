var _sel = (obj_shop_bg.shop_button_select == button_index);
image_index = _sel ? 1 : 0;

// 刚被选中 → 从头播一次回弹
if (_sel && !tab_sel_last) { tab_pop_t = 0 }
tab_sel_last = _sel;
tab_pop_t += ui_anim_dt();

var _s = 1.8;
if (_sel && ui_anim_on(1)) {
var _p  = clamp(tab_pop_t / 0.18, 0, 1);
var _c1 = 1.70158;
var _e  = 1 + (_c1 + 1) * power(_p - 1, 3) + _c1 * power(_p - 1, 2);   // ease-out back
_s = 1.8 * lerp(0.92, 1, _e);
}
image_xscale = _s;
image_yscale = _s;
