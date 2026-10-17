// 处理滑块拖动
if (dragging) {
    current_x = clamp(mouse_x, min_x, max_x);
    update_volume();
	x = current_x
}

// 检查鼠标释放
if (dragging && !mouse_check_button(mb_left)) {
    dragging = false;
    save_volume();
}


if (!dragging) {
	if (volume_type == "music") {
	    x = min_x + global.music_volume * (max_x - min_x)
	} else if (volume_type == "sound") {
	    x = min_x + global.sound_volume * (max_x - min_x)
	}
	// 星星是独立对象、位置每帧由音量重算，需自己叠加面板的标签页偏移 pg_shift
	// （x 已在上面叠加 pg_shift）
	if (instance_exists(obj_config_menu)) {
	    x += obj_config_menu.pg_shift;
	}
}
