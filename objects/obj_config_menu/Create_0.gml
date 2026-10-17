image_xscale = 1;
image_yscale = 1;
button_select = 0;
current_settings = noone; // 当前设置页面的控制器
setting_buttons = []; // 存储创建的设置按钮

// 创建界面按钮
closemenu_btn = instance_create_depth(x+470, y-330, depth-1, obj_closemenu_btn);
menu_btn1 = instance_create_depth(x-360, y-245, depth-1, obj_menu_select_btn);
menu_btn2 = instance_create_depth(x-120, y-245, depth-1, obj_menu_select_btn);
menu_btn3 = instance_create_depth(x+120, y-245, depth-1, obj_menu_select_btn);
menu_btn4 = instance_create_depth(x+360, y-245, depth-1, obj_menu_select_btn);

menu_btn2.button_index = 1;
menu_btn3.button_index = 2;
menu_btn4.button_index = 3;

menu_btn2.sprite_index = spr_option_select_btn_2
menu_btn3.sprite_index = spr_option_select_btn_3
menu_btn4.sprite_index = spr_option_select_btn_4

// 添加操作设置相关变量
keybind_page = 0; // 当前快捷键设置页
keybinds_per_page = 5; // 每页显示的快捷键数量
total_keybind_pages = 0; // 总页数

// 计算总页数
total_keybind_pages = ceil(array_length(global.keybind_config) / keybinds_per_page);

/// @function create_keybind_buttons()
// 创建当前页的快捷键按钮
function create_keybind_buttons(){
	var start_index = keybind_page * keybinds_per_page;
	var end_index = min(start_index + keybinds_per_page, array_length(global.keybind_config)) - 1;

	var base_y = y - 50;
	for (var i = start_index; i <= end_index; i++) {
	    var kb = global.keybind_config[i];
	    var btn = instance_create_depth(x+270, base_y + (i - start_index) * 70, depth-1, obj_key_bind_button);
	    btn.key_name = kb.name;
	    btn.default_key = kb.default1;
	    btn.current_key = global.keybind_map[? kb.name];
	    //btn.tooltip_text = kb.tooltip;
	    btn.update_text();
	    array_push(setting_buttons, btn);
	}
}

// 难度切换动画（点左右箭头时，等级名在卡片容器里滑出/滑入）
diff_shown       = global.difficulty;  // 当前应显示的那一帧（动画的"上一帧"）
diff_anim_from   = global.difficulty;  // 正在离开的那一帧
diff_anim_t      = -1;                 // -1 = 无动画；>=0 = 动画进行到第几帧
diff_anim_frames = 18;                 // 时长（帧），60fps ≈ 0.3s
diff_anim_dir    = 1;                  // 1 = 下一级（新图从右侧进）；-1 = 上一级（从左侧进）
diff_anim_pad    = 52;                 // 裁剪窗口比等级名左右各宽多少；再宽就会溢出到卡片外
global.vol_intro_p = -1;           // Draw_0 会读；恒为 -1 表示音量条不播入场
pg_shift           = 0;            // 标签页切换时整页的横向偏移（独立子对象如 obj_volume_slider 要自己加回去）

// 动效分级三档滑块（「画面设置」页第 6 行；档位 0/1/2 = 关闭/基础/完全，存 global.ui_anim）
// 行位 y+330：上面五行开关在 y-170..y+230，同为 100 间距，且不出面板内区
ui_anim_slider_dx = [-290, -200, -110]; // 三档相对 x 的偏移（0=关闭 1=基础 2=完全；与 Draw_0 case 2 同一组数字）
ui_anim_slider_dy = 330;                // 滑块行相对 y 的偏移
ui_anim_knob_dx   = ui_anim_slider_dx[clamp(ui_anim_level(), 0, 2)]; // 旋钮当前显示位置（相对 x），开局先对齐当前档位
ui_anim_drag      = false;              // 是否正在拖动
ui_anim_snap_p    = 1;                  // 吸附回弹进度（1 = 已到位）
ui_anim_snap_from = -200;               // 回弹起点（相对 x）
ui_anim_snap_frames = 12;               // 回弹时长（帧），60fps ≈ 0.2s

// ── 标签页切换：整页朝切换方向位移 + 淡入（旧页当帧消失，不做退场）──
pg_t      = -1;    // -1 = 无动画；>=0 = 动画进行到第几帧（0 = 位移最大、全透明）
pg_frames = 13;    // 时长（帧），60fps ≈ 0.22s
pg_dir    = 1;     // 1 = 新页自右侧进；-1 = 自左侧进（按标签序号差算）
pg_slide  = 60;    // 位移幅度（px）—— 刻意不超出面板内区，所以子按钮不需要裁剪
pg_surf   = -1;    // 页面内容的录制面（只在切页那 0.22s 里存在）
pg_base_x = [];    // 本页子对象的基准 x（各 page 创建按钮时记录）
pg_win_l  = x - 460;   // 页面内容窗口：面板自己画的那部分按这个窗口贴回来
pg_win_t  = y - 220;
pg_win_w  = 880;
pg_win_h  = 560;

// ── 打开/关闭动效：整块从下方滑入 + 淡入（统一接口，说明见 scripts/GuiStack/GuiStack.gml 顶部）──
// 子对象类型每帧自动补登记：切标签页后动态创建的那批按钮也会跟着一起动
panel_anim_init(id, 0.28, 0.18, 260);
panel_anim_kids(id, [obj_closemenu_btn, obj_menu_select_btn,
                     obj_setting_toggle, obj_volume_slider, obj_mute_button,
                     obj_key_bind_button, obj_page_button, obj_difficulty_select_btn]);
