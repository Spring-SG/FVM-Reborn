if not obj_shop_bg.is_submenu_opened{
global.audio.play(snd_button,0,0)
panel_anim_close(obj_shop_bg)      // 反向滑出 + 淡出，播完由 panel_anim_step 销毁
}