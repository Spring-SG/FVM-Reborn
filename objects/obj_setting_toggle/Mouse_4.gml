// 切换状态
state = !state;
audio_play_sound(snd_button,0,0)
// 保存到配置文件
if (config_key != "") {
    ini_open("config.ini");
    ini_write_real("settings", config_key, state);
    ini_close();
}

// 应用设置（如果需要立即生效）
if (config_key == "screen_shake") {
    global.screen_shake = state;
} else if (config_key == "screen_flash") {
    global.screen_flash = state;
}
else if (config_key == "fullscreen") {
    global.fullscreen = state;
	window_set_fullscreen(global.fullscreen)
}
else if (config_key == "replace_placement"){
	global.replace_placement = state
}
else if (config_key == "quick_placement"){
	global.quick_placement = state
}
else if (config_key == "card_hpbar"){
	global.card_hpbar = state
}
else if (config_key == "enemy_hpbar"){
	global.enemy_hpbar = state
}
else if (config_key == "tex_fliter"){
	global.tex_fliter = state
	gpu_set_tex_filter(global.tex_fliter)
}
else if (config_key == "difficulty"){
	global.difficulty = state
}
else if (config_key == "borderless_window"){
	global.borderless_window = state
	window_enable_borderless_fullscreen(global.borderless_window)
}
else if (config_key == "lose_focus_pause"){
	global.lose_focus_pause = state
}