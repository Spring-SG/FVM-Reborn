// ═══════════════════════════════════════════════════════════════════════════
// 控制台（默认 ~ 键）——持久对象：随 room_init 创建，跨房间存活
//   开关：global.console_enabled（config.ini → [settings] console_enabled）
//   按键：config.ini → [keybinds] 控制台（设置面板「操作设置」页可改）
//   指令实现：scripts/console_commands
// ═══════════════════════════════════════════════════════════════════════════

depth = -15000;               // Draw GUI 里压在所有界面之上（GMS 合法深度范围约 ±16000，越界会导致不绘制）

console_open      = false;    // 面板是否展开（与 global.console_open 同步）
console_input     = "";       // 当前输入行
console_log       = [];       // 输出日志（最多 console_max_lines 行）
console_max_lines = 300;
console_scroll    = 0;        // 向上滚动的行数（0 = 停在最新）
console_hist      = [];       // 历史命令
console_hist_pos  = -1;       // 历史定位（-1 = 不在浏览历史）
console_caret     = 0;        // 光标闪烁计时
console_just_opened = false;  // 打开后跳过一帧输入（吞掉触发键本身）
console_last_tab_sig = "";  // 上一次 Tab 列出的候选签名（避免同一个列表重复刷屏）

/// @function console_fit(_line)
// 把超宽的一行截断到面板宽度内（只在入栈时算一次，绘制时零开销）
function console_fit(_line) {
	draw_set_font(font_hei);
	var _max_w = display_get_gui_width() - 48 - 28;
	if (string_width(_line) <= _max_w) return _line;
	var _s = _line;
	while (string_length(_s) > 1 && string_width(_s + "…") > _max_w) {
		_s = string_delete(_s, string_length(_s), 1);
	}
	return _s + "…";
}

/// @function console_push(_line)
// 追加一行输出，超出上限从最旧的开始丢
function console_push(_line) {
	_line = console_fit(_line);
	array_push(console_log, _line);
	while (array_length(console_log) > console_max_lines) {
		array_delete(console_log, 0, 1);
	}
}

/// @function console_open_now()
function console_open_now() {
	console_open         = true;
	global.console_open  = true;
	console_just_opened  = true;
	console_input        = "";
	console_scroll       = 0;
	console_hist_pos     = -1;
	console_last_tab_sig = "";
	keyboard_string      = "";
	console_push("FVM:Reborn 控制台 — 输入 help 查看指令，~ / Esc 关闭");
}

/// @function console_close()
function console_close() {
	console_open        = false;
	global.console_open = false;
	console_input       = "";
	console_hist_pos    = -1;
	keyboard_string     = "";
}

/// @function console_submit()
// 回车：执行当前输入
function console_submit() {
	var _line = console_trim(console_input);
	console_input    = "";
	console_scroll   = 0;
	console_hist_pos = -1;
	console_last_tab_sig = "";
	if (_line == "") return;

	console_push("> " + _line);
	array_push(console_hist, _line);
	if (array_length(console_hist) > 50) array_delete(console_hist, 0, 1);

	// clear 只影响本地日志，不经过指令表
	if (string_lower(_line) == "clear") {
		console_log = [];
		return;
	}

	var _res = console_run(_line);
	for (var i = 0; i < array_length(_res); i++) {
		console_push(_res[i]);
	}
}