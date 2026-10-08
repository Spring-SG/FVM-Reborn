
    if (not audio_is_playing(readyroom_music)) {
        // 停止可能存在的暂停实例
        audio_stop_sound(readyroom_music);
        // 从头开始播放新实例
        global.audio.play(readyroom_music, 0, 0);
    }
if keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right){
	if instance_exists(obj_quit_confirm){
		instance_destroy(obj_quit_confirm)
	}
	else{
		if !is_submenu_open{
			instance_create_depth(room_width / 2,room_height / 2,-100,obj_quit_confirm)
		}
	}
}

if instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview){
	is_submenu_open = true
}
else{
	is_submenu_open = false
}

// 卡槽快捷键：悬停卡池卡片 + 按「卡槽 N」= 精确放入第 N 槽（N 与右侧槽位号一致）
// 目标槽不在当前页时先翻页，否则卡片会落在看不见的那一页
if (hover_card_index != -1 && !is_submenu_open && !instance_exists(obj_package_bg)) {
	var _hot_card = global.player_deck[| hover_card_index * 2]
	for (var _k = 1; _k <= deck_slot_max(); _k++) {
		var _hot_key = global.keybind_map[? "卡槽" + string(_k)]
		if (_hot_key == undefined) continue
		if (!keyboard_check_pressed(_hot_key)) continue

		var _hot_slot = _k - 1
		var _hot_page = (_hot_slot >= 11) ? 10 : 0
		if (deck_first_slot_index != _hot_page) deck_first_slot_index = _hot_page

		global.audio.play(snd_button, 0, 0)
		add_to_deck(_hot_card, get_card_info_simple(_hot_card).shape, _hot_slot)
		break
	}
}

