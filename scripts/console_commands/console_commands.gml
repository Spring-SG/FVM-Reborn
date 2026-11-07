/// ═══════════════════════════════════════════════════════════════════════════
/// 控制台指令（obj_console 的唯一入口）
///   console_run(_input) 解析一行输入 → 执行 → 返回「输出行数组」，由 obj_console 追加到日志。
///
/// 指令一览：
///   give <material_id> [amount]
///   unlock card <card_id> [level] [shape] [skill]
///   unlock weapon <weapon_id>
///   unlock gem <gem_id> [level]
///   complete_level <level_id>
///   edit card <card_id> [level|shape|skill|max_level|max_shape <值>] ...
///   debug
///   unlock_all
///   help / clear
///
/// 开关：global.console_enabled（config.ini → [settings] console_enabled，默认 true）
///       为 false 时 ~ 键不再响应，console_run 也直接拒绝执行。
/// ═══════════════════════════════════════════════════════════════════════════

#macro CONSOLE_SKILL_MAX     8    // 技能等级上限（卡片资料约定）
#macro CONSOLE_GEM_LEVEL_MAX 15   // 宝石等级上限

/// @function console_trim(_s)
/// @desc 去掉首尾空格 / 制表符
function console_trim(_s) {
	var _a = 1;
	var _l = string_length(_s);
	while (_a <= _l && (string_char_at(_s, _a) == " " || string_char_at(_s, _a) == "\t")) _a++;
	while (_l >= _a && (string_char_at(_s, _l) == " " || string_char_at(_s, _l) == "\t")) _l--;
	if (_l < _a) return "";
	return string_copy(_s, _a, _l - _a + 1);
}

/// @function console_tokenize(_s)
/// @desc 按空白切分参数（行内参数都很短，逐字符处理没有性能问题）
function console_tokenize(_s) {
	var _out = [];
	var _cur = "";
	var _len = string_length(_s);
	for (var i = 1; i <= _len; i++) {
		var _c = string_char_at(_s, i);
		if (_c == " " || _c == "\t") {
			if (_cur != "") { array_push(_out, _cur); _cur = ""; }
		} else {
			_cur += _c;
		}
	}
	if (_cur != "") array_push(_out, _cur);
	return _out;
}

/// @function console_to_int(_s, _def)
/// @desc 参数 → 整数；不是纯数字（可带前导负号）时返回 _def
function console_to_int(_s, _def) {
	if (is_undefined(_s)) return _def;
	var _len = string_length(_s);
	if (_len == 0) return _def;
	for (var i = 1; i <= _len; i++) {
		var _c = string_char_at(_s, i);
		var _is_digit = (_c >= "0" && _c <= "9");
		if (!_is_digit && !(_c == "-" && i == 1)) return _def;
	}
	return real(_s);
}

/// @function console_join_ids(_array, _limit)
/// @desc 把 id 数组拼成一行（超过 _limit 个就截断）
function console_join_ids(_array, _limit) {
	var _n = array_length(_array);
	var _s = "";
	for (var i = 0; i < min(_n, _limit); i++) {
		if (i > 0) _s += ", ";
		_s += string(_array[i]);
	}
	if (_n > _limit) _s += " …（共 " + string(_n) + " 个）";
	return _s;
}

/// @function console_ds_keys(_map, _limit)
/// @desc ds_map 的 key 列表 → 一行字符串
function console_ds_keys(_map, _limit) {
	if (is_undefined(_map)) return "";
	return console_join_ids(ds_map_keys_to_array(_map), _limit);
}

/// @function console_card_limits(_card_id)
/// @desc 从植物注册表读「卡片资料」里真实的等级 / 形态上限
/// @return {struct} {exists, name, max_level, max_shape}
function console_card_limits(_card_id) {
	var _res = { exists: false, name: "", max_level: 0, max_shape: 0 };
	if (!ds_map_exists(global.plant_registry, _card_id)) return _res;

	var _plant  = global.plant_registry[? _card_id];
	var _shapes = _plant[? "shapes"];
	var _skeys  = ds_map_keys_to_array(_shapes);

	for (var i = 0; i < array_length(_skeys); i++) {
		var _shape_id = real(_skeys[i]);
		if (_shape_id > _res.max_shape) _res.max_shape = _shape_id;

		var _shape = _shapes[? _skeys[i]];
		if (i == 0) _res.name = _shape[? "name"];

		// 该形态下所有 upgrade 的 level 最大值 = 这张卡能到的最高等级
		var _up    = _shape[? "upgrades"];
		var _ukeys = ds_map_keys_to_array(_up);
		for (var j = 0; j < array_length(_ukeys); j++) {
			var _lv = real(_ukeys[j]);
			if (_lv > _res.max_level) _res.max_level = _lv;
		}
	}

	_res.exists = true;
	return _res;
}

/// @function console_card_index(_card_id)
/// @desc 已解锁卡片在 save_data.unlocked_cards 里的下标；未解锁返回 -1
function console_card_index(_card_id) {
	for (var i = 0; i < array_length(global.save_data.unlocked_cards); i++) {
		if (global.save_data.unlocked_cards[i].id == _card_id) return i;
	}
	return -1;
}

/// @function console_usage()
function console_usage() {
	return [
		"give <material_id> <amount>            给予材料",
		"unlock card <card_id> [level] [shape] [skill]   解锁卡片（超过卡片资料上限自动取上限）",
		"unlock weapon <weapon_id>              解锁武器",
		"unlock gem <gem_id> [level]            解锁宝石（等级上限 15）",
		"complete_level <level_id>              标记关卡已通关",
		"edit card <card_id> [level|shape|skill|max_level|max_shape <值>] ...   编辑卡片，不带参数显示当前数据",
		"debug                                  切换 global.debug",
		"unlock_all                             执行 obj_game_init 的 unlock_all()",
		"clear                                  清空控制台输出",
		"任意 id 位置写 ? 可列出全部可用 ID"
	];
}

// ── give ───────────────────────────────────────────────────────────────────
function console_cmd_give(_args, _out) {
	var _id = array_get(_args, 0);
	if (is_undefined(_id)) {
		array_push(_out, "用法：give <material_id> <amount>");
		return;
	}
	if (_id == "?") {
		array_push(_out, "材料 ID：" + console_ds_keys(global.material_pool, 40));
		return;
	}
	if (!ds_map_exists(global.material_pool, _id)) {
		array_push(_out, "[错误] 未找到材料：" + _id + "（用 give ? 列出全部）");
		return;
	}
	var _amount = console_to_int(array_get(_args, 1), 1);
	if (_amount <= 0) {
		array_push(_out, "[错误] 数量必须是正整数（也可以省略，默认 1）");
		return;
	}
	var _info = get_material_info(_id);
	var _name = (is_struct(_info) && struct_exists(_info, "name")) ? _info[$ "name"] : _id;
	add_material_amount(_id, _amount);
	array_push(_out, "已给予 " + string(_name) + " ×" + string(_amount) + "，当前持有 " + string(get_material_amount(_id)));
}

// ── unlock card ────────────────────────────────────────────────────────────
function console_cmd_unlock_card(_args, _out) {
	var _id = array_get(_args, 0);
	if (is_undefined(_id)) {
		array_push(_out, "用法：unlock card <card_id> [level] [shape] [skill]");
		return;
	}
	if (_id == "?") {
		array_push(_out, "卡片 ID：" + console_ds_keys(global.plant_registry, 40));
		return;
	}
	var _lim = console_card_limits(_id);
	if (!_lim.exists) {
		array_push(_out, "[错误] 未找到卡片：" + _id + "（用 unlock card ? 列出全部）");
		return;
	}

	var _lv = console_to_int(array_get(_args, 1), 0);
	var _sh = console_to_int(array_get(_args, 2), 0);
	var _sk = console_to_int(array_get(_args, 3), 0);

	var _lv_c = clamp(_lv, 0, _lim.max_level);
	var _sh_c = clamp(_sh, 0, _lim.max_shape);
	var _sk_c = clamp(_sk, 0, CONSOLE_SKILL_MAX);

	unlock_card(_id, _lv_c, _sh_c, _sk_c);

	array_push(_out, "已解锁卡片 " + string(_lim.name) + "（" + _id + "）：level=" + string(_lv_c)
		+ " shape=" + string(_sh_c) + " skill=" + string(_sk_c));
	if (_lv != _lv_c || _sh != _sh_c || _sk != _sk_c) {
		array_push(_out, "  已按上限修正（level 上限 " + string(_lim.max_level)
			+ "，shape 上限 " + string(_lim.max_shape)
			+ "，skill 上限 " + string(CONSOLE_SKILL_MAX) + "）");
	}
}

// ── unlock weapon ──────────────────────────────────────────────────────────
function console_cmd_unlock_weapon(_args, _out) {
	var _id = array_get(_args, 0);
	if (is_undefined(_id)) {
		array_push(_out, "用法：unlock weapon <weapon_id>");
		return;
	}
	if (_id == "?") {
		array_push(_out, "武器 ID：" + console_ds_keys(global.weapon_pool, 40));
		return;
	}
	if (!ds_map_exists(global.weapon_pool, _id)) {
		array_push(_out, "[错误] 未找到武器：" + _id + "（用 unlock weapon ? 列出全部）");
		return;
	}
	if (is_weapon_unlocked(_id)) {
		array_push(_out, "武器 " + _id + " 已经解锁过了");
		return;
	}
	unlock_weapon(_id);
	var _info = global.weapon_pool[? _id];
	var _name = struct_exists(_info, "name") ? _info[$ "name"] : _id;
	array_push(_out, "已解锁武器 " + string(_name) + "（" + _id + "）");
}

// ── unlock gem ─────────────────────────────────────────────────────────────
function console_cmd_unlock_gem(_args, _out) {
	var _id = array_get(_args, 0);
	if (is_undefined(_id)) {
		array_push(_out, "用法：unlock gem <gem_id> [level]");
		return;
	}
	if (_id == "?") {
		array_push(_out, "宝石 ID：" + console_ds_keys(global.gems_pool, 40));
		return;
	}
	if (!ds_map_exists(global.gems_pool, _id)) {
		array_push(_out, "[错误] 未找到宝石：" + _id + "（用 unlock gem ? 列出全部）");
		return;
	}

	var _lv   = console_to_int(array_get(_args, 1), 0);
	var _lv_c = clamp(_lv, 0, CONSOLE_GEM_LEVEL_MAX);

	unlock_gem(_id);
	edit_gem_level(_id, _lv_c);
	edit_gem_max_level(_id, _lv_c);
	save_file(global.save_slot);

	var _info = global.gems_pool[? _id];
	var _name = struct_exists(_info, "name") ? _info[$ "name"] : _id;
	array_push(_out, "已解锁宝石 " + string(_name) + "（" + _id + "）：level=" + string(_lv_c));
	if (_lv != _lv_c) {
		array_push(_out, "  等级已按上限修正（宝石上限 " + string(CONSOLE_GEM_LEVEL_MAX) + "）");
	}
	// 宝石对象运行时会再按 gem_info.max_level 夹一次，这里提醒一下差值
	if (struct_exists(_info, "max_level") && _lv_c > _info[$ "max_level"]) {
		array_push(_out, "  注意：该宝石的数据上限是 " + string(_info[$ "max_level"]) + "，实际生效等级会被夹到该值");
	}
}

// ── complete_level ─────────────────────────────────────────────────────────
function console_cmd_complete_level(_args, _out) {
	var _id = array_get(_args, 0);
	if (is_undefined(_id)) {
		array_push(_out, "用法：complete_level <level_id>");
		return;
	}
	if (_id == "?") {
		array_push(_out, "关卡 ID：" + console_join_ids(global.level_id_list, 40));
		return;
	}
	if (array_get_index(global.level_id_list, _id) == -1) {
		array_push(_out, "[错误] 未找到关卡：" + _id + "（用 complete_level ? 列出全部）");
		return;
	}
	if (is_level_completed(_id)) {
		array_push(_out, "关卡 " + _id + " 已经标记为通关了");
		return;
	}
	complete_level(_id);
	array_push(_out, "已标记通关：" + _id);
}

// ── edit card ──────────────────────────────────────────────────────────────
/// @function console_cmd_edit_card(_args, _out)
/// @desc 不带参数 = 打印当前数据；带参数按 level/shape/skill/max_level/max_shape 逐项改
///       取值同样受卡片资料上限约束；支持 "level 5" 与 "level=5" 两种写法。
function console_cmd_edit_card(_args, _out) {
	var _id = array_get(_args, 0);
	if (is_undefined(_id)) {
		array_push(_out, "用法：edit card <card_id> [level|shape|skill|max_level|max_shape <值>] ...");
		return;
	}
	var _idx = console_card_index(_id);
	if (_idx == -1) {
		array_push(_out, "[错误] 卡片 " + _id + " 未解锁（先用 unlock card " + _id + " 解锁）");
		return;
	}

	var _lim  = console_card_limits(_id);
	var _card = global.save_data.unlocked_cards[_idx];
	var _name = _lim.exists ? string(_lim.name) : _id;

	// 不带参数：打印当前数据
	if (array_length(_args) < 2) {
		array_push(_out, "卡片 " + _name + "（" + _id + "）当前数据：");
		array_push(_out, "  level=" + string(_card.level) + "/" + string(_card.max_level)
			+ "  shape=" + string(_card.shape) + "/" + string(_card.max_shape)
			+ "  skill=" + string(_card.skill));
		if (_lim.exists) {
			array_push(_out, "  卡片资料上限：level " + string(_lim.max_level)
				+ "  shape " + string(_lim.max_shape)
				+ "  skill " + string(CONSOLE_SKILL_MAX));
		}
		return;
	}

	// 带参数：逐项编辑
	var _changed = 0;
	var _i = 1;
	while (_i < array_length(_args)) {
		var _token = _args[_i];
		var _key   = "";
		var _value = "";
		var _eq    = string_pos("=", _token);
		if (_eq > 0) {
			_key   = string_lower(string_copy(_token, 1, _eq - 1));
			_value = string_delete(_token, 1, _eq);
			_i += 1;
		} else {
			_key = string_lower(_token);
			if (_i + 1 >= array_length(_args)) {
				array_push(_out, "[错误] 参数 " + _key + " 缺少数值");
				break;
			}
			_value = _args[_i + 1];
			_i += 2;
		}

		var _num = console_to_int(_value, undefined);
		if (is_undefined(_num)) {
			array_push(_out, "[错误] " + _key + " 的值不是整数：" + string(_value));
			continue;
		}

		var _cap   = 0;
		var _valid = true;
		switch (_key) {
			case "level":     _cap = _lim.exists ? _lim.max_level : 999;  break;
			case "max_level": _cap = _lim.exists ? _lim.max_level : 999;  break;
			case "shape":     _cap = _lim.exists ? _lim.max_shape : 999;  break;
			case "max_shape": _cap = _lim.exists ? _lim.max_shape : 999;  break;
			case "skill":     _cap = CONSOLE_SKILL_MAX;                   break;
			default:          _valid = false;                             break;
		}
		if (!_valid) {
			array_push(_out, "[错误] 不认识的字段：" + _key + "（可选 level / shape / skill / max_level / max_shape）");
			continue;
		}

		var _clamped = clamp(_num, 0, _cap);
		switch (_key) {
			case "level":     _card.level     = _clamped; break;
			case "max_level": _card.max_level = _clamped; break;
			case "shape":     _card.shape     = _clamped; break;
			case "max_shape": _card.max_shape = _clamped; break;
			case "skill":     _card.skill     = _clamped; break;
		}
		_changed += 1;
		if (_clamped != _num) {
			array_push(_out, "  " + _key + "：" + string(_num) + " 超出上限，已改为 " + string(_clamped));
		} else {
			array_push(_out, "  " + _key + " = " + string(_clamped));
		}
	}

	if (_changed > 0) {
		save_file(global.save_slot);
		array_push(_out, "已保存卡片 " + _name + "（" + _id + "）：level=" + string(_card.level)
			+ " shape=" + string(_card.shape) + " skill=" + string(_card.skill)
			+ " max_level=" + string(_card.max_level) + " max_shape=" + string(_card.max_shape));
	}
}

// ── debug ──────────────────────────────────────────────────────────────────
function console_cmd_debug(_out) {
	global.debug = !global.debug;
	array_push(_out, "global.debug = " + string(global.debug));
}

// ── unlock_all ─────────────────────────────────────────────────────────────
/// @function console_cmd_unlock_all(_out)
/// @desc 执行 obj_game_init 的 unlock_all()。
///       该函数是 obj_game_init 的实例方法（不是全局函数），所以必须从那个实例上调；
///       obj_game_init 已设为 persistent，跨房间存活，因此这里能一直取到它。
function console_cmd_unlock_all(_out) {
	if (!instance_exists(obj_game_init)) {
		array_push(_out, "[错误] obj_game_init 实例不存在，无法执行 unlock_all()");
		return;
	}
	with (obj_game_init) {
		unlock_all();
	}
	array_push(_out, "已执行 unlock_all()（测试版初始存档）");
}

// ── 入口 ───────────────────────────────────────────────────────────────────
/// @function console_run(_input)
/// @desc 执行一行控制台输入，返回输出行数组
function console_run(_input) {
	var _out = [];

	if (!global.console_enabled) {
		array_push(_out, "[错误] 控制台当前不可用（config.ini → [settings] console_enabled = false）");
		return _out;
	}

	var _args = console_tokenize(_input);
	if (array_length(_args) == 0) return _out;

	var _cmd = string_lower(_args[0]);
	array_delete(_args, 0, 1);

	switch (_cmd) {
		case "help":
			_out = console_usage();
			break;

		case "give":
			console_cmd_give(_args, _out);
			break;

		case "unlock": {
			var _sub = array_get(_args, 0);
			if (is_undefined(_sub)) {
				array_push(_out, "用法：unlock card|weapon|gem <id> …");
				break;
			}
			_sub = string_lower(_sub);
			array_delete(_args, 0, 1);
			if (_sub == "card")        console_cmd_unlock_card(_args, _out);
			else if (_sub == "weapon") console_cmd_unlock_weapon(_args, _out);
			else if (_sub == "gem")    console_cmd_unlock_gem(_args, _out);
			else array_push(_out, "[错误] unlock 后面只能跟 card / weapon / gem");
			break;
		}

		case "complete_level":
			console_cmd_complete_level(_args, _out);
			break;

		case "edit": {
			var _sub2 = array_get(_args, 0);
			if (is_undefined(_sub2) || string_lower(_sub2) != "card") {
				array_push(_out, "用法：edit card <card_id> [level|shape|skill|max_level|max_shape <值>] ...");
				break;
			}
			array_delete(_args, 0, 1);
			console_cmd_edit_card(_args, _out);
			break;
		}

		case "debug":
			console_cmd_debug(_out);
			break;

		case "unlock_all":
			console_cmd_unlock_all(_out);
			break;

		default:
			array_push(_out, "[错误] 未知指令：" + _cmd + "（输入 help 查看全部指令）");
			break;
	}

	return _out;
}