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
	    var btn1 = instance_create_depth(x - 200, y - 170, depth-2, obj_setting_toggle);
	    btn1.config_key = "screen_shake";
	    btn1.state = global.screen_shake;
		btn1.tooltip_text = "炸弹造成的屏幕震动效果"
	    array_push(setting_buttons, btn1);
    
	    // 创建闪烁效果开关
	    var btn2 = instance_create_depth(x - 200, y - 70, depth-2, obj_setting_toggle);
	    btn2.config_key = "screen_flash";
	    btn2.state = global.screen_flash;
		btn2.tooltip_text = "冰桶、开水壶等造成的屏幕闪烁效果\n如果您对游戏画面感到不适，请关闭该选项，并及时就医。"
	    array_push(setting_buttons, btn2);
		
		// 创建全屏开关
	    var btn3 = instance_create_depth(x - 200, y + 30, depth-1, obj_setting_toggle);
	    btn3.config_key = "fullscreen";
	    btn3.state = global.fullscreen;
	    array_push(setting_buttons, btn3);
		
		// 创建纹理过滤开关
	    var btn4 = instance_create_depth(x - 200, y + 130, depth-1, obj_setting_toggle);
	    btn4.config_key = "tex_fliter";
	    btn4.state = global.tex_fliter;
		btn4.tooltip_text = "开启此选项可以改善画质"
	    array_push(setting_buttons, btn4);
		
		// 创建无边框窗口开关
	    var btn5 = instance_create_depth(x - 200, y + 230, depth-1, obj_setting_toggle);
	    btn5.config_key = "borderless_window";
	    btn5.state = global.borderless_window;
		btn5.tooltip_text = "将全屏变为无边框窗口模式\n该选项只会在你下一次切换全屏时生效"
	    array_push(setting_buttons, btn5);
    
		// 动效分级滑块：重新进入本页时旋钮直接对齐当前档位（不播回弹）
		ui_anim_knob_dx = ui_anim_slider_dx[clamp(ui_anim_level(), 0, 2)];
		ui_anim_snap_p  = 1;
		ui_anim_drag    = false;
    
	    // 标记当前设置页面
	    current_settings = id;
	    // 记录本页子对象的基准 x：标签页滑动以此为原点（每个 page 创建按钮后各记一次）
	    pg_base_x = [];
	    for (var _pg_b = 0; _pg_b < array_length(setting_buttons); _pg_b++) {
	        if (instance_exists(setting_buttons[_pg_b])) pg_base_x[_pg_b] = setting_buttons[_pg_b].x;
	    }
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
	    var btn1 = instance_create_depth(x - 200, y - 140, depth-1, obj_setting_toggle);
	    btn1.config_key = "card_hpbar";
	    btn1.state = global.card_hpbar;
	    array_push(setting_buttons, btn1);
		
		// 创建敌人血条开关
	    var btn2 = instance_create_depth(x - 200, y - 40, depth-1, obj_setting_toggle);
	    btn2.config_key = "enemy_hpbar";
	    btn2.state = global.enemy_hpbar;
	    array_push(setting_buttons, btn2);
		
		// 创建难度开关
	    var btn3 = instance_create_depth(x - 200, y + 110, depth-1, obj_difficulty_select_btn);
	    btn3.config_key = "difficulty";
	    btn3.state = global.difficulty;
		btn3.b_type = "prev"
	    array_push(setting_buttons, btn3);
		var btn32 = instance_create_depth(x + 225, y + 110, depth-1, obj_difficulty_select_btn);
	    btn32.config_key = "difficulty";
	    btn32.state = global.difficulty;
		btn32.b_type = "next"
		btn32.image_xscale = -0.9
	    array_push(setting_buttons, btn32);
		
		// 创建失焦暂停开关
	    var btn4 = instance_create_depth(x - 200, y + 260, depth-1, obj_setting_toggle);
	    btn4.config_key = "lose_focus_pause";
	    btn4.state = global.lose_focus_pause;
		btn4.tooltip_text = "切换窗口时，游戏自动暂停"
	    array_push(setting_buttons, btn4);
    
	    // 标记当前设置页面
	    current_settings = id;
	    // 记录本页子对象的基准 x：标签页滑动以此为原点（每个 page 创建按钮后各记一次）
	    pg_base_x = [];
	    for (var _pg_b = 0; _pg_b < array_length(setting_buttons); _pg_b++) {
	        if (instance_exists(setting_buttons[_pg_b])) pg_base_x[_pg_b] = setting_buttons[_pg_b].x;
	    }
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
	    var slider_min_x = x - 280;
	    var slider_max_x = x + 280;
	    var slider_y = y - 135;
    
	    // global.vol_intro_p 恒为 -1：音量条不播入场

// 创建音乐滑块
	    var slider_music = instance_create_depth(slider_min_x, slider_y, depth-1, obj_volume_slider);
	    slider_music.volume_type = "music";
	    slider_music.min_x = slider_min_x;
	    slider_music.max_x = slider_max_x;
	    slider_music.current_x = slider_min_x + (slider_max_x - slider_min_x) * global.music_volume;
	    array_push(setting_buttons, slider_music);
    
	    // 创建音乐静音按钮
	    var mute_music = instance_create_depth(slider_max_x + 52, slider_y+3, depth-1, obj_mute_button);
	    mute_music.volume_type = "music";
	    array_push(setting_buttons, mute_music);
    
	    // 创建音效滑块
	    slider_y += 98;
	    var slider_sound = instance_create_depth(slider_min_x, slider_y, depth-1, obj_volume_slider);
	    slider_sound.volume_type = "sound";
	    slider_sound.min_x = slider_min_x;
	    slider_sound.max_x = slider_max_x;
	    slider_sound.current_x = slider_min_x + (slider_max_x - slider_min_x) * global.sound_volume;
	    array_push(setting_buttons, slider_sound);
    
	    // 创建音效静音按钮
	    var mute_sound = instance_create_depth(slider_max_x + 52, slider_y+3, depth-1, obj_mute_button);
	    mute_sound.volume_type = "sound";
	    array_push(setting_buttons, mute_sound);
    
	    // 标记当前设置页面
	    current_settings = id;
	    // 记录本页子对象的基准 x：标签页滑动以此为原点（每个 page 创建按钮后各记一次）
	    pg_base_x = [];
	    for (var _pg_b = 0; _pg_b < array_length(setting_buttons); _pg_b++) {
	        if (instance_exists(setting_buttons[_pg_b])) pg_base_x[_pg_b] = setting_buttons[_pg_b].x;
	    }
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
	    var btn1 = instance_create_depth(x - 240, y - 170, depth-2, obj_setting_toggle);
	    btn1.config_key = "replace_placement";
	    btn1.tooltip_text = "放置卡片后自动移除本格原有的卡片";
	    ini_open("config.ini");
	    btn1.state = ini_read_bool("settings", "replace_placement", false);
	    ini_close();
	    array_push(setting_buttons, btn1);
    
	    var btn2 = instance_create_depth(x + 200, y - 170, depth-2, obj_setting_toggle);
	    btn2.config_key = "quick_placement";
	    btn2.tooltip_text = "按下快捷键后直接将卡片放置在鼠标对应位置\n该选项对铲子生效，开启该选项会自动关闭放置预览";
	    ini_open("config.ini");
	    btn2.state = ini_read_bool("settings", "quick_placement", false);
	    ini_close();
	    array_push(setting_buttons, btn2);
    
	    // 创建快捷键绑定按钮（当前页）
	    create_keybind_buttons();
    
	    // 创建翻页按钮
	    var prev_btn = instance_create_depth(x - 200, y + 295, depth-1, obj_page_button);
	    prev_btn.text = "上一页";
	    prev_btn.action = "prev_page";
	    array_push(setting_buttons, prev_btn);
    
	    var next_btn = instance_create_depth(x + 200, y + 295, depth-1, obj_page_button);
	    next_btn.text = "下一页";
	    next_btn.action = "next_page";
	    array_push(setting_buttons, next_btn);
    
	    // 标记当前设置页面
	    current_settings = id;
	    // 记录本页子对象的基准 x：标签页滑动以此为原点（每个 page 创建按钮后各记一次）
	    pg_base_x = [];
	    for (var _pg_b = 0; _pg_b < array_length(setting_buttons); _pg_b++) {
	        if (instance_exists(setting_buttons[_pg_b])) pg_base_x[_pg_b] = setting_buttons[_pg_b].x;
	    }
	}
}


// ── 难度切换动画：检测 global.difficulty 变化并推进计时（与 Draw_0 case 3 的滑出/滑入配套）──
if (global.difficulty != diff_shown) {
    diff_anim_from = diff_shown;
    diff_shown     = global.difficulty;
    if (ui_anim_on(1)) {                    // 等级名滑动从「基础」档起；等级 0 直接换图，不走动画
        diff_anim_t = 0;
        var _d4     = (diff_shown - diff_anim_from + 4) mod 4;
        diff_anim_dir = (_d4 == 1) ? 1 : -1;   // 1 = 下一级（新图从右侧进）；其余（含 3→0 回绕）当上一级
    } else {
        diff_anim_t = -1;
    }
}
if (diff_anim_t >= 0) {
    diff_anim_t++;
    if (diff_anim_t >= diff_anim_frames) diff_anim_t = -1;
}

// （这里不再有音量条入场的计时）

// ══════════════════════ 动效分级三档滑块（「画面设置」页第 6 行；绘制在 Draw_0 case 2）══════════════════════
// 三档：0 = 关闭 / 1 = 基础 / 2 = 完全，读写的就是 scripts/GuiStack/GuiStack.gml 的 global.ui_anim
/// @function ui_anim_nearest_stop(_dx)
// 旋钮的相对 x → 最近的档位（0/1/2）
function ui_anim_nearest_stop(_dx){
	var _step = (ui_anim_slider_dx[2] - ui_anim_slider_dx[0]) / 2;  // 三档等距，半档 = 吸附半径
	return clamp(round((_dx - ui_anim_slider_dx[0]) / _step), 0, 2);
}

/// @function ui_anim_slider_apply(_level)
// 落到某一档：夹到 0..2 → 更新 global.ui_anim → 写 config.ini → 播按钮音（值没变就不写盘不出声）
function ui_anim_slider_apply(_level){
	_level = clamp(round(_level), 0, 2);
	if (_level != clamp(ui_anim_level(), 0, 2)) {
		global.ui_anim = _level;
		ini_open("config.ini");
		ini_write_real("settings", "ui_anim", _level);
		ini_close();
		global.audio.play(snd_button, 0, 0);
	}
}

/// @function ui_anim_slider_step()
// 拖动/点击 1:1 跟手；松手后按 ease-out 吸附到最近档位
function ui_anim_slider_step(){
	var _row_y = y + ui_anim_slider_dy;
	var _x0    = x + ui_anim_slider_dx[0];
	var _x2    = x + ui_anim_slider_dx[2];

	// 在滑块行内按下（横向各留 16px 余量）：开始拖动。点某一档也走这条路——按下即 1:1 跟手
	if (mouse_check_button_pressed(mb_left) &&
		point_in_rectangle(mouse_x, mouse_y, _x0 - 16, _row_y - 20, _x2 + 16, _row_y + 20)) {
		ui_anim_drag   = true;
		ui_anim_snap_p = 1;
	}

	if (ui_anim_drag) {
		if (mouse_check_button(mb_left)) {
			ui_anim_knob_dx = clamp(mouse_x, _x0, _x2) - x;             // 拖动 1:1，不吸附
			ui_anim_slider_apply(ui_anim_nearest_stop(ui_anim_knob_dx)); // 档位名与动效实时跟着走
		} else {
			ui_anim_drag = false;
			ui_anim_slider_apply(ui_anim_nearest_stop(ui_anim_knob_dx));
			ui_anim_snap_from = ui_anim_knob_dx;   // 松手：从当前位置回弹到落定的档位
			ui_anim_snap_p    = 0;
		}
	}

	// 吸附回弹：cubic ease-out（起步快、收尾慢；与难度名滑出/滑入同一套缓动），不用线性匀速
	if (!ui_anim_drag && ui_anim_snap_p < 1) {
		ui_anim_snap_p = min(1, ui_anim_snap_p + 1 / ui_anim_snap_frames);
		var _e = 1 - (1 - ui_anim_snap_p) * (1 - ui_anim_snap_p) * (1 - ui_anim_snap_p);
		ui_anim_knob_dx = ui_anim_snap_from
		                + (ui_anim_slider_dx[clamp(ui_anim_level(), 0, 2)] - ui_anim_snap_from) * _e;
	}
}

// 只有停在「画面设置」页才响应滑块；切走时清掉拖动状态
if (button_select == 2) {
	ui_anim_slider_step();
} else {
	ui_anim_drag = false;
}

// ── 标签页切换：整页位移 + 淡入的推进与施加（缓动/位移量与 Draw_0 的视口偏移严格同源）──
// 只写 x / image_alpha 两个通道；入场期间（pnl_o < 0.999）不写：kid-sync 会覆盖它们。
if (pg_t >= 0) {
	var _pg_ease  = 1 - (1 - pg_t / pg_frames) * (1 - pg_t / pg_frames) * (1 - pg_t / pg_frames);
	var _pg_shift = pg_dir * pg_slide * (1 - _pg_ease);
	pg_shift = _pg_shift;   // 暴露给独立子对象（obj_volume_slider 的星星自己补这个偏移）
	if (pnl_o >= 0.999) {
		for (var _pg_i = 0; _pg_i < array_length(setting_buttons); _pg_i++) {
			if (instance_exists(setting_buttons[_pg_i])) {
				if (_pg_i < array_length(pg_base_x)) {
					setting_buttons[_pg_i].x = pg_base_x[_pg_i] + _pg_shift;
				}
				setting_buttons[_pg_i].image_alpha = _pg_ease;
			}
		}
	}
	pg_t++;
	if (pg_t > pg_frames) {
		pg_t = -1;
		pg_shift = 0;   // 收尾：偏移归零（星星自己补的就是这个值）
		// 收尾：x 归基准、alpha 归 1，并把录制面还回去
		for (var _pg_j = 0; _pg_j < array_length(setting_buttons); _pg_j++) {
			if (instance_exists(setting_buttons[_pg_j])) {
				if (_pg_j < array_length(pg_base_x)) setting_buttons[_pg_j].x = pg_base_x[_pg_j];
				setting_buttons[_pg_j].image_alpha = 1;
			}
		}
		if surface_exists(pg_surf) surface_free(pg_surf);
		pg_surf = -1;
	}
}
