/// @function save_file(file_slot, allow_prompt)
/// @desc 将全局变量global.save_data保存到存档文件中，并在写完后校验文件内容
/// @param {real} file_slot 存档槽位
/// @param {bool} allow_prompt 校验失败时是否弹窗（退出游戏流程里传 false，避免模态框卡住关闭）
/// @returns {bool} 是否确认写入成功
function save_file(file_slot, allow_prompt = true) {
	var file_path = "saves/"+"save" + string(file_slot) + ".json"
    // 将数据转换为JSON字符串
    var json_string = json_stringify(global.save_data);
    
    // 打开文件进行写入
    var file = file_text_open_write(file_path);
    if (file == -1) {
        show_debug_message("无法创建存档文件!");
		return save_file_report_failure(file_path, "无法创建存档文件", allow_prompt);
    }
    
    // 写入数据
    file_text_write_string(file, json_string);
    file_text_close(file);

	// 写完立刻回读校验：把文件内容读回来，与内存中的存档比较。
	// GameMaker 的写入失败是静默的（不抛异常、退出码正常），只能靠回读确认；
	// 少了这一步，玩家会以为存上了，下次启动却回到旧进度。
	// 注意：JSON 字符串里不会有真实换行（换行会被转义成 \n 两个字符），
	// 这里再抹掉 \r 只是为了兼容文本模式可能做的行尾转换。
	var read_back = save_file_read_back(file_path);
	if (string_replace_all(read_back, "\r", "") != string_replace_all(json_string, "\r", "")) {
		return save_file_report_failure(file_path, "回读的文件内容与内存中的存档不一致", allow_prompt);
	}
    
    show_debug_message("存档保存成功!");
    return true;
}

/// @function save_file_read_back(_path)
/// @desc 把存档文件原样读回内存；文件不存在或读取失败返回空串
/// @param {String} _path
/// @returns {String}
function save_file_read_back(_path) {
	if (!file_exists(_path)) {
		return "";
	}
	var _buffer = buffer_load(_path);
	if (!buffer_exists(_buffer)) {
		return "";
	}
	var _text = "";
	if (buffer_get_size(_buffer) > 0) {
		_text = buffer_read(_buffer, buffer_string);
	}
	buffer_delete(_buffer);
	return _text;
}

/// @function save_file_report_failure(_path, _reason, _allow_prompt)
/// @desc 存档写入/校验失败后的统一处理：
///         第 1、2 次弹窗 —— 确定 = 继续游戏，取消 = 退出游戏；
///         第 3 次及以后 —— 无论确定还是取消都退出游戏，并附上四种排查建议。
/// @param {String} _path 出问题的存档路径（仅用于日志）
/// @param {String} _reason 失败原因（写进弹窗）
/// @param {Bool} _allow_prompt 是否允许弹窗
/// @returns {Bool} 恒为 false，方便调用方直接 return
function save_file_report_failure(_path, _reason, _allow_prompt) {
	if (!variable_global_exists("save_fail_count")) {
		global.save_fail_count = 0;
	}
	global.save_fail_count++;
	show_debug_message("[SAVE] 存档保存失败（本次运行第 " + string(global.save_fail_count) + " 次）：" + _reason + " @" + _path);

	// 退出流程里不能弹模态框，否则玩家关不掉游戏
	if (!_allow_prompt) {
		return false;
	}

	var _message = "存档无法保存！\n\n"
		+ "游戏没能把内存中的存档写入文件（" + _reason + "），\n"
		+ "本次游戏进度可能会丢失。";

	// 第 3 次：确定或取消都退出，并给出四种排查方式
	if (global.save_fail_count >= 3) {
		_message += "\n\n本次运行已经连续 " + string(global.save_fail_count) + " 次无法保存存档，游戏即将退出。\n"
			+ "可以按下面几种方式排查：\n"
			+ "1. 右键游戏程序，选择「以管理员身份运行」\n"
			+ "2. 检查杀毒软件设置，把游戏和存档目录加入信任/白名单\n"
			+ "3. 检查存档目录的读取与写入权限\n"
			+ "4. 在游戏中主动使用备份功能，避免进度全部丢失";
		show_question(_message);
		game_end();
		return false;
	}

	// 第 1、2 次：确定（是）= 继续游戏，取消（否）= 退出游戏
	_message += "\n点击「是」继续游戏，点击「否」退出游戏。";
	if (!show_question(_message)) {
		game_end();
	}
	return false;
}
