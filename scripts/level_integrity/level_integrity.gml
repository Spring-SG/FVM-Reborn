/// @file level_integrity
/// @description 关卡文件完整性校验：内存中的关卡内容 vs scripts/level_hashes 里的离线哈希表。
///
/// 背景：GameMaker 的 buffer_load / file_text_* 在权限不足、杀毒软件拦截、中文路径等
/// 情况下会**静默失败** —— 返回空内容或半截内容而不报错。关卡数据一旦读坏，战斗会从
/// 错误的网格/波次上运行，既没有崩溃也没有提示，表现为「关卡数据混乱」。
/// 所以每次读关卡都把内存里拿到的内容按同一算法算一遍哈希，与编译进游戏的表比对。
///
/// 哈希表必须放在 GML 资源里（scripts/level_hashes），不能放 datafiles ——
/// datafiles 本身也会被静默读坏，用它做基准等于用不可信数据校验不可信数据。
///
/// 算法必须与 tools/gen_level_hashes.py 的 level_hash() 逐字节一致：
///   双 32 位状态，逐字节 rotate/xor/add 混合（不用 64 位乘法，避开 double 精度问题），
///   跳过空格 \t \n \r，最后把「参与哈希的字节数」也混进去。
///
/// ⚠️ 只在缓冲区上做，不要在字符串上做：GML 的 string_byte_at 是按 UTF-8 逐字符定位的
///    O(n) 操作，几万字节的关卡会退化成 O(n²)（实测 836KB 的文件要 60 秒）；
///    buffer_peek 是 O(1)，同一份文件约 0.2 秒。别改回去。

/// @function level_integrity_hash_buffer(_buffer)
/// @description 计算缓冲区内容的内容哈希（16 位小写十六进制）；算法见文件头
/// @param {Id.Buffer} _buffer 已读入内存的关卡文件缓冲区
/// @returns {String}
function level_integrity_hash_buffer(_buffer) {
	var _len = buffer_get_size(_buffer)
	// 关卡文件末尾普遍带一个 \x00 终止符，不计入内容
	while (_len > 0 && buffer_peek(_buffer, _len - 1, buffer_u8) == 0) {
		_len--
	}
	// 常量用十进制写死（0x811C9DC5 / 0x9E3779B9 / 0x7F4A7C15 / 0x165667B1 / 0x85EBCA6B）：
	// 超过 2^31 的十六进制字面量在不同编译器下有无符号歧义，十进制没有这个问题
	var _mask = 4294967295
	var _h1 = 2166136261
	var _h2 = 2654435769
	var _count = 0
	for (var i = 0; i < _len; i++) {
		var _b = buffer_peek(_buffer, i, buffer_u8)
		// 忽略空白：空格 9 10 13 32 —— 让哈希只与 JSON 语义字节有关，
		// 不受缩进和 CRLF/LF 差异影响（.gitattributes 把 *.json 归一成 LF，
		// Windows 检出时又是 CRLF，两种检出的字节数不一样）
		if (_b == 32 || _b == 9 || _b == 10 || _b == 13) {
			continue
		}
		_count++
		_h1 = (_h1 ^ _b) & _mask
		_h1 = ((_h1 << 13) | (_h1 >> 19)) & _mask
		_h1 = (_h1 + (_h1 << 5) + 2135587861) & _mask
		_h2 = (_h2 + _b + 374761393) & _mask
		_h2 = _h2 ^ (_h2 >> 15)
		_h2 = (_h2 * 3 + 2246822507) & _mask
	}
	// 非空白字节数参与最后一步：读到半截内容时，即使前缀完全相同也能区分出来
	_h1 = (_h1 + _count) & _mask
	_h2 = (_h2 ^ _count) & _mask
	return level_integrity_hex(_h1) + level_integrity_hex(_h2)
}

/// @function level_integrity_hex(_value)
/// @description 32 位无符号整数转 8 位小写十六进制
/// @param {Real} _value
/// @returns {String}
function level_integrity_hex(_value) {
	var _chars = "0123456789abcdef"
	var _out = ""
	for (var i = 7; i >= 0; i--) {
		var _nib = (_value >> (i * 4)) & 15
		_out += string_char_at(_chars, _nib + 1)
	}
	return _out
}

/// @function level_integrity_get_expected(_file_path)
/// @description 从哈希表里取某个关卡文件的期望哈希
/// @param {String} _file_path buffer_load 使用的路径（如 "level_data/tower/tower-1-1.json"）
/// @returns {String|Undefined} 未登记（模组关卡、自定义关卡）时返回 undefined
function level_integrity_get_expected(_file_path) {
	var _key = string_replace_all(string(_file_path), "\\", "/")
	var _tbl = level_hashes_get()
	if (variable_struct_exists(_tbl, _key)) {
		return _tbl[$ _key]
	}
	return undefined
}

/// @function level_integrity_is_enabled()
/// @description 是否校验关卡文件。global.level_hash_verify 由 obj_game_init 设置：
///              测试版（正在改关卡数据）把它设为 false 即可跳过校验。
/// @returns {Bool}
function level_integrity_is_enabled() {
	if (!variable_global_exists("level_hash_verify")) {
		return true
	}
	return global.level_hash_verify
}

/// @function level_load_json_verified(_file_path)
/// @description 读取并解析关卡 JSON，读不出来或内容校验不通过时返回 Result.fail。
///              调用方负责失败处理（一般是退回 room_map + show_notice）。
/// @param {String} _file_path buffer_load 使用的路径
/// @returns {Struct.Result<Struct>} data = 解析后的关卡结构
function level_load_json_verified(_file_path) {
	var _buffer = buffer_load(_file_path)
	if (!buffer_exists(_buffer)) {
		return new Result().fail(ErrorCode.NO_SUCH_FILE, "无法读取关卡文件（buffer_load 失败）：" + _file_path)
	}
	if (buffer_get_size(_buffer) <= 0) {
		buffer_delete(_buffer)
		return new Result().fail(ErrorCode.NO_SUCH_FILE, "关卡文件内容为空：" + _file_path)
	}

	// 内容校验：直接对内存里这份缓冲区算哈希，与离线生成的表比对。
	// buffer_peek 是绝对偏移，不受下面 buffer_read 改变读写位置的影响。
	if (level_integrity_is_enabled()) {
		var _expected = level_integrity_get_expected(_file_path)
		if (is_undefined(_expected)) {
			// 模组 / 自定义关卡不在表里，跳过校验（它们的文件由玩家自己提供）
			show_debug_message("[LEVEL] 未登记的关卡文件，跳过校验：" + _file_path)
		}
		else {
			var _actual = level_integrity_hash_buffer(_buffer)
			if (_actual != _expected) {
				var _size = buffer_get_size(_buffer)
				buffer_delete(_buffer)
				return new Result().fail(ErrorCode.HASH_MISMATCH,
					"关卡文件校验失败：" + _file_path
					+ "（期望 " + _expected + "，实际 " + _actual
					+ "，长度 " + string(_size) + " 字节）")
			}
		}
	}

	var _json_string = buffer_read(_buffer, buffer_string)
	buffer_delete(_buffer)

	if (!is_string(_json_string) || string_byte_length(_json_string) == 0) {
		return new Result().fail(ErrorCode.NO_SUCH_FILE, "关卡文件内容为空：" + _file_path)
	}

	try {
		var _json = json_parse(_json_string)
		if (!is_struct(_json) && !is_array(_json)) {
			return new Result().fail(ErrorCode.JSON_PARSE_FAILED, "关卡 JSON 根节点类型异常：" + _file_path)
		}
		return new Result().success(_json)
	}
	catch (_e) {
		return new Result().fail(ErrorCode.JSON_PARSE_FAILED, "关卡 JSON 解析失败：" + _file_path + "\n" + string(_e))
	}
}

/// @function level_load_failed_back_to_map(_file_path, _reason)
/// @description 关卡读取失败的统一处理：先退回 room_map，再提示关卡文件读取失败
/// @param {String} _file_path 出问题的路径（只用于日志）
/// @param {String} _reason 失败原因（只用于日志）
function level_load_failed_back_to_map(_file_path, _reason) {
	show_debug_message("[LEVEL] 关卡加载失败：" + string(_reason))
	if (global.gui_stack.get_top() != room_map) {
		global.gui_stack.to(room_map)
	}
	// 150 帧 ≈ 2.5 秒：要盖过房间切换的淡出淡入，否则提示会看不见
	show_notice("关卡文件读取失败", 150)
}