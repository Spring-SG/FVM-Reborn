if not obj_info_island_bg.is_submenu_opened{
global.audio.play(snd_button,0,0)
panel_anim_close(obj_info_island_bg)     // 播完反向过渡再销毁（销毁在 panel_anim_step 里）
}