

if not obj_tower_cake_bg.is_submenu_opened{
	var level_list = global.maps_map[? "tower_cake"].levels_data
	global.level_data = level_list[level_index]

	global.level_id = global.level_data.id
	var _file_path = "level_data/" + global.level_data.level_file
	if global.difficulty >= 2{
		_file_path = "level_data/" + global.level_data.hard_level_file
	}

	// 读取关卡文件并校验内存中的内容（GameMaker 会静默读坏文件，见 scripts/level_integrity）
	var _load_result = level_load_json_verified(_file_path);
	if (_load_result.is_failed()) {
		// 先退回地图，再提示读取失败；不要留在食神谱里
		level_load_failed_back_to_map(_file_path, _load_result.message);
		exit;
	}
	global.level_file = _load_result.data;

	if obj_tower_cake_bg.level_select != btn_index{
		obj_tower_cake_bg.level_select = btn_index
		obj_tower_cake_bg.real_level_index = level_index
		global.audio.play(snd_button,0,0)
		with obj_tower_cake_bg{
			refresh_reward_button()
		}
	}
	obj_tower_cake_start_btn.is_unlocked = is_unlocked
}
