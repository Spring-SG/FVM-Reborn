// 根据当前选中的菜单显示不同内容
switch (button_select) {
    case 2: // 画面设置
        draw_settings_page();
        break;
	case 3:
		draw_games_page()
		break
    
    case 0: // 音乐设置
        draw_audio_page();
        break;
	case 1:
		draw_controls_page();
		break;
		
	default:
		for (var i = 0; i < array_length(setting_buttons); i++) {
	        if (instance_exists(setting_buttons[i])) {
	            instance_destroy(setting_buttons[i]);
	        }
	    }
	    setting_buttons = [];
}


// 只有首次进入该页面时创建按钮
function draw_settings_page(){
	if (!instance_exists(current_settings)) {
	    // 销毁旧按钮
	    for (var i = 0; i < array_length(setting_buttons); i++) {
	        if (instance_exists(setting_buttons[i])) {
	            instance_destroy(setting_buttons[i]);
	        }
	    }
	    setting_buttons = [];
    
	    // 创建屏幕震动开关
	    var btn1 = instance_create_depth(x - 200, y - 180, depth-1, obj_setting_toggle);
	    btn1.config_key = "screen_shake";
	    btn1.state = global.screen_shake;
		btn1.tooltip_text = "炸弹造成的屏幕震动效果"
	    array_push(setting_buttons, btn1);
    
	    // 创建闪烁效果开关
	    var btn2 = instance_create_depth(x - 200, y - 100, depth-1, obj_setting_toggle);
	    btn2.config_key = "screen_flash";
	    btn2.state = global.screen_flash;
		btn2.tooltip_text = "冰桶、开水壶等造成的屏幕闪烁效果\n如果您对游戏画面感到不适，请关闭该选项，并及时就医。"
	    array_push(setting_buttons, btn2);
		
		// 创建全屏开关
	    var btn3 = instance_create_depth(x - 200, y - 20, depth-1, obj_setting_toggle);
	    btn3.config_key = "fullscreen";
	    btn3.state = global.fullscreen;
	    array_push(setting_buttons, btn3);
		
		// 创建纹理过滤开关
	    var btn4 = instance_create_depth(x - 200, y + 60, depth-1, obj_setting_toggle);
	    btn4.config_key = "tex_fliter";
	    btn4.state = global.tex_fliter;
		btn4.tooltip_text = "开启此选项可以改善画质"
	    array_push(setting_buttons, btn4);
		
		// 创建无边框窗口开关
	    var btn5 = instance_create_depth(x - 200, y + 140, depth-1, obj_setting_toggle);
	    btn5.config_key = "borderless_window";
	    btn5.state = global.borderless_window;
		btn5.tooltip_text = "将全屏变为无边框窗口模式\n该选项只会在你下一次切换全屏时生效"
	    array_push(setting_buttons, btn5);
    
	    // 标记当前设置页面
	    current_settings = id;
	}
}

function draw_games_page(){
	if (!instance_exists(current_settings)) {
	    // 销毁旧按钮
	    for (var i = 0; i < array_length(setting_buttons); i++) {
	        if (instance_exists(setting_buttons[i])) {
	            instance_destroy(setting_buttons[i]);
	        }
	    }
	    setting_buttons = [];
    
	    
		
		// 创建植物血条开关
	    var btn1 = instance_create_depth(x - 180, y - 180, depth-1, obj_setting_toggle);
	    btn1.config_key = "card_hpbar";
	    btn1.state = global.card_hpbar;
	    array_push(setting_buttons, btn1);
		
		// 创建敌人血条开关
	    var btn2 = instance_create_depth(x - 180, y - 100, depth-1, obj_setting_toggle);
	    btn2.config_key = "enemy_hpbar";
	    btn2.state = global.enemy_hpbar;
	    array_push(setting_buttons, btn2);
		
		// 创建难度开关
	    var btn3 = instance_create_depth(x - 200, y - 20, depth-1, obj_difficulty_select_btn);
	    btn3.config_key = "difficulty";
	    btn3.state = global.difficulty;
	    array_push(setting_buttons, btn3);
		
		// 创建失焦暂停开关
	    var btn4 = instance_create_depth(x - 180, y + 60, depth-1, obj_setting_toggle);
	    btn4.config_key = "lose_focus_pause";
	    btn4.state = global.lose_focus_pause;
	    array_push(setting_buttons, btn4);
    
	    // 标记当前设置页面
	    current_settings = id;
	}
}

function draw_audio_page(){
	if (!instance_exists(current_settings)) {
	    // 销毁旧按钮
	    for (var i = 0; i < array_length(setting_buttons); i++) {
	        if (instance_exists(setting_buttons[i])) {
	            instance_destroy(setting_buttons[i]);
	        }
	    }
	    setting_buttons = [];
    
	    // 定义滑块位置
	    var slider_min_x = x - 320;
	    var slider_max_x = x + 80;
	    var slider_y = y - 142;
    
	    // 创建音乐滑块
	    var slider_music = instance_create_depth(slider_min_x, slider_y, depth-1, obj_volume_slider);
	    slider_music.volume_type = "music";
	    slider_music.min_x = slider_min_x;
	    slider_music.max_x = slider_max_x;
	    slider_music.current_x = slider_min_x + (slider_max_x - slider_min_x) * global.music_volume;
	    array_push(setting_buttons, slider_music);
    
	    // 创建音乐静音按钮
	    var mute_music = instance_create_depth(slider_max_x + 60, slider_y, depth-1, obj_mute_button);
	    mute_music.volume_type = "music";
	    array_push(setting_buttons, mute_music);
    
	    // 创建音效滑块
	    slider_y += 80;
	    var slider_sound = instance_create_depth(slider_min_x, slider_y, depth-1, obj_volume_slider);
	    slider_sound.volume_type = "sound";
	    slider_sound.min_x = slider_min_x;
	    slider_sound.max_x = slider_max_x;
	    slider_sound.current_x = slider_min_x + (slider_max_x - slider_min_x) * global.sound_volume;
	    array_push(setting_buttons, slider_sound);
    
	    // 创建音效静音按钮
	    var mute_sound = instance_create_depth(slider_max_x + 60, slider_y, depth-1, obj_mute_button);
	    mute_sound.volume_type = "sound";
	    array_push(setting_buttons, mute_sound);
    
	    // 标记当前设置页面
	    current_settings = id;
	}	
}

/// @function draw_controls_page()
// 只有首次进入该页面时创建按钮
function draw_controls_page(){
	if (!instance_exists(current_settings)) {
	    // 销毁旧按钮
	    for (var i = 0; i < array_length(setting_buttons); i++) {
	        if (instance_exists(setting_buttons[i])) {
	            instance_destroy(setting_buttons[i]);
	        }
	    }
	    setting_buttons = [];
    
	    // 创建两个开关：替换放置和快速放置
	    var btn1 = instance_create_depth(x - 200, y - 170, depth-1, obj_setting_toggle);
	    btn1.config_key = "replace_placement";
	    btn1.tooltip_text = "放置卡片后自动移除本格原有的卡片";
	    ini_open("config.ini");
	    btn1.state = ini_read_bool("settings", "replace_placement", false);
	    ini_close();
	    array_push(setting_buttons, btn1);
    
	    var btn2 = instance_create_depth(x + 200, y - 170, depth-1, obj_setting_toggle);
	    btn2.config_key = "quick_placement";
	    btn2.tooltip_text = "按下快捷键后直接将卡片放置在鼠标对应位置\n该选项对铲子生效，开启该选项会自动关闭放置预览";
	    ini_open("config.ini");
	    btn2.state = ini_read_bool("settings", "quick_placement", false);
	    ini_close();
	    array_push(setting_buttons, btn2);
    
	    // 创建快捷键绑定按钮（当前页）
	    create_keybind_buttons();
    
	    // 创建翻页按钮
	    var prev_btn = instance_create_depth(x - 250, y + 300, depth-1, obj_page_button);
	    prev_btn.text = "上一页";
	    prev_btn.action = "prev_page";
	    array_push(setting_buttons, prev_btn);
    
	    var next_btn = instance_create_depth(x + 250, y + 300, depth-1, obj_page_button);
	    next_btn.text = "下一页";
	    next_btn.action = "next_page";
	    array_push(setting_buttons, next_btn);
    
	    // 标记当前设置页面
	    current_settings = id;
	}
}

