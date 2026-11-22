/// @function key_to_string(key)
/// @description 将键盘键值转换为可读的字符串
/// @param {real} key 键盘键值
/// @return {string} 键名字符串
function keyboard_get_string(key){

	// 处理特殊键值
	switch (key) {
	    // 功能键
	    case vk_backspace: return "Backspace";
	    case vk_tab: return "Tab";
	    case vk_return: return "Enter";
	    case vk_shift: return "Shift";
		case vk_lshift: return "左Shift";
		case vk_rshift: return "右Shift";
	    case vk_control: return "Ctrl";
		case vk_lcontrol: return "左Ctrl";
		case vk_rcontrol: return "右Ctrl";
		case vk_alt: return "Alt";
	    case vk_lalt: return "左Alt";
		case vk_ralt: return "右Alt";
	    case vk_pause: return "Pause";
	    case 20: return "Caps Lock";
	    case vk_escape: return "Esc";
	    case vk_space: return "Space";
	    case vk_pageup: return "Page Up";
	    case vk_pagedown: return "Page Down";
	    case vk_end: return "End";
	    case vk_home: return "Home";
	    case vk_left: return "←";
	    case vk_up: return "↑";
	    case vk_right: return "→";
	    case vk_down: return "↓";
	    case vk_printscreen: return "Print Screen";
	    case vk_insert: return "Insert";
	    case vk_delete: return "Delete";
    
	    // 数字小键盘
	    case vk_numpad0: return "Num 0";
	    case vk_numpad1: return "Num 1";
	    case vk_numpad2: return "Num 2";
	    case vk_numpad3: return "Num 3";
	    case vk_numpad4: return "Num 4";
	    case vk_numpad5: return "Num 5";
	    case vk_numpad6: return "Num 6";
	    case vk_numpad7: return "Num 7";
	    case vk_numpad8: return "Num 8";
	    case vk_numpad9: return "Num 9";
	    case 106: return "Num *";
	    case vk_add: return "Num +";
	    case vk_subtract: return "Num -";
	    case vk_decimal: return "Num .";
	    case vk_divide: return "Num /";
	    case 144: return "Num Lock";
    
	    // 功能键
	    case vk_f1: return "F1";
	    case vk_f2: return "F2";
	    case vk_f3: return "F3";
	    case vk_f4: return "F4";
	    case vk_f5: return "F5";
	    case vk_f6: return "F6";
	    case vk_f7: return "F7";
	    case vk_f8: return "F8";
	    case vk_f9: return "F9";
	    case vk_f10: return "F10";
	    case vk_f11: return "F11";
	    case vk_f12: return "F12";
    
	    // 其他特殊键
	    case 91: return "Win";
	    case 93: return "Apps";
	    case 145: return "Scroll Lock";
    
	    // 鼠标按钮（可选）
	    case mb_left: return "Mouse Left";
	    case mb_middle: return "Mouse Middle";
	    case mb_right: return "Mouse Right";
    
	    // 字母键 - 直接转换
	    default:
	        // A-Z (65-90)
	        if (key >= 65 && key <= 90) {
	            return chr(key);
	        }
        
	        // 数字键 0-9 (48-57)
	        if (key >= 48 && key <= 57) {
	            return chr(key);
	        }
        
	        // 符号键
	        switch (key) {
	            case 186: return ";";
	            case 187: return "=";
	            case 188: return ",";
	            case 189: return "-";
	            case 190: return ".";
	            case 191: return "/";
	            case 192: return "~";   // ~ / ` 键（控制台默认键位）
	            case 219: return "[";
	            case 220: return "\\";
	            case 221: return "]";
	            case 222: return "'";
	        }
        
	        // 无法识别的键值
	        return "Key " + string(key);
	}
}