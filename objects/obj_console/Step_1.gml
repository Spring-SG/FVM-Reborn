// ═══════════════════════════════════════════════════════════════════════════
// 用 Begin Step：比所有其它对象的 Step 都早。
// 控制台展开时会先在这里把 global.console_open 置位，其它对象据此跳过按键，
// 于是打字不会触发卡槽热键 / 空格暂停 / ESC 返回。
// ═══════════════════════════════════════════════════════════════════════════

// global.console_enabled = false 时整套输入都不响应（键位配置也留着，只是不生效）
if (!global.console_enabled) {
	if (console_open) console_close();
	exit;
}

// ── 开关键 ──
var _key = global.keybind_map[? "控制台"];
if (!is_undefined(_key) && _key != -1) {
	var _pressed = keyboard_check_pressed(_key);
	// ~ 是 OEM 键：不同布局/运行时下 keyboard_check 拿到的码可能是 192 / 96( ` ) / 126( ~ )，都认
	if (!_pressed && _key == 192) {
		_pressed = keyboard_check_pressed(96) || keyboard_check_pressed(126);
	}
	if (_pressed) {
		if (console_open) console_close(); else console_open_now();
	}
}

// 刚打开的这一帧丢掉键盘缓冲，否则触发键本身会变成输入行的第一个字符
if (console_just_opened) {
	keyboard_string     = "";
	console_just_opened = false;
	exit;
}

if (!console_open) exit;

console_caret++;

// ── 文本输入 ──
var _typed = keyboard_string;
if (string_length(_typed) > 0) {
	console_input += _typed;
	keyboard_string = "";
	console_hist_pos = -1;
}

// ── 退格 ──
if (keyboard_check_pressed(vk_backspace)) {
	var _len = string_length(console_input);
	if (_len > 0) console_input = string_delete(console_input, _len, 1);
}

// ── 回车执行 ──
if (keyboard_check_pressed(vk_return)) {
	console_submit();
}

// ── 上下翻历史 ──
if (keyboard_check_pressed(vk_up) && array_length(console_hist) > 0) {
	if (console_hist_pos == -1) {
		console_hist_pos = array_length(console_hist) - 1;
	} else if (console_hist_pos > 0) {
		console_hist_pos -= 1;
	}
	console_input = console_hist[console_hist_pos];
}
if (keyboard_check_pressed(vk_down)) {
	if (console_hist_pos != -1) {
		console_hist_pos += 1;
		if (console_hist_pos >= array_length(console_hist)) {
			console_hist_pos = -1;
			console_input = "";
		} else {
			console_input = console_hist[console_hist_pos];
		}
	}
}

// ── 滚动 ──
if (mouse_wheel_up())   console_scroll += 2;
if (mouse_wheel_down()) console_scroll -= 2;
if (keyboard_check_pressed(vk_pageup))   console_scroll += 10;
if (keyboard_check_pressed(vk_pagedown)) console_scroll -= 10;
console_scroll = clamp(console_scroll, 0, max(0, array_length(console_log) - 1));

// ── ESC 关闭（不落到下层菜单）──
if (keyboard_check_pressed(vk_escape)) {
	console_close();
	exit;
}

// ── 屏蔽鼠标：控制台展开期间点击不穿透到下面的界面 ──
// mouse_clear 会让该按钮在物理松开前一直被当作未按下
mouse_clear(mb_left);
mouse_clear(mb_right);
mouse_clear(mb_middle);