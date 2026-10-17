panel_anim_step(id)
if (!instance_exists(id)) { exit }

if global.menu_screen{
	draw_set_alpha(0.5 * ui_anim_alpha(id));
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}
panel_anim_begin(id)
draw_self()
draw_sprite(spr_option_menu_bg_2,0,x,y+75)
draw_set_font(font_yuan)
draw_set_color(c_white)
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
//draw_text_ext_transformed(x,y-345,"游戏设置",0,900,2,2,0)

// ── 标签页切换：整页朝切换方向位移 + 淡入 ──
// 面板自己画的内容（各 case）先录进 pg_surf，再按视口反向偏移贴回来 —— 于是"整页平移"不用改
// case 里任何一个坐标。子按钮走 Step_0 的 x 偏移，两边同一条缓动、同一个位移量。
// 入场期间（pnl_o < 0.999）不播：kid-sync 会覆盖同一批属性。
var _pg_anim  = (pg_t >= 0 && pnl_o >= 0.999);
var _pg_ease  = 1;
var _pg_shift = 0;
var _pg_live  = false;
if (_pg_anim) {
	var _pg_p = pg_t / pg_frames;
	_pg_ease  = 1 - (1 - _pg_p) * (1 - _pg_p) * (1 - _pg_p);
	_pg_shift = pg_dir * pg_slide * (1 - _pg_ease);
	if (!surface_exists(pg_surf)) pg_surf = surface_create(room_width, room_height);
	if (surface_exists(pg_surf)) {
		surface_set_target(pg_surf);
		draw_clear_alpha(c_black, 0);
		_pg_live = true;
	}
}
draw_set_alpha(1);

switch (button_select) {
    case 2: // 画面设置
        //绘制设置标签
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_middle);
		//draw_text(x - 380, y - 180, "屏幕震动");
		//draw_text(x - 380, y - 100, "闪烁效果");
		//draw_text(x - 380, y - 20, "全屏");
		//draw_text(x - 380, y + 60, "纹理过滤");
		//draw_text(x - 380, y + 140, "无边框窗口");
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_top);
		draw_sprite(spr_option_menu_text,1,x-360,y+30)

		// ── 动效分级：三档滑块（左→右 = 关闭 / 基础 / 完全，档位即 global.ui_anim）──
		var _sy   = y + ui_anim_slider_dy;          // 第 6 行（上面五行开关在 y-170..y+230，同 100 间距）
		var _sx0  = x + ui_anim_slider_dx[0];       // 档位 0：关闭
		var _sx2  = x + ui_anim_slider_dx[2];       // 档位 2：完全
		var _knob = x + ui_anim_knob_dx;            // 旋钮当前显示位置（拖动 1:1 / 松手 ease-out 回弹）
		var _lvl  = clamp(ui_anim_level(), 0, 2);
		var _name = "基础";
		switch (_lvl) {
			case 0: _name = "关闭"; break;
			case 2: _name = "完全"; break;
		}

		// 行标签（与上面五行贴图标签同列 x-360 居中）
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_color(c_white);
		// 行标签贴图（与上面五行贴图标签同款）
                draw_sprite_ext(spr_option_anim_label, 0, x - 360, y + 330, 1, 1, 0, c_white, 1);

		// 轨道：圆角条纹贴图（spr_option_anim_bar = 音量条贴图削成胶囊）；没播到的部分用音量页同款深色盖住
		// → 关闭：整条深色；基础：左半条纹；完全：整条条纹
		var _bar_w = sprite_get_width(spr_option_anim_bar);
		// 贴图原点在正中，故按轨道中点绘制
			draw_sprite_ext(spr_option_anim_bar, 0, (_sx0 + _sx2) * 0.5, _sy, (_sx2 - _sx0) / _bar_w, 0.8, 0, c_white, 1);
		if (_sx2 - _knob > 2) {
			draw_set_color(#17314C);
			draw_roundrect_ext(_knob, _sy - 10, _sx2, _sy + 10, 10, 10, false);   // 右端跟着轨道一样圆
		}


		// 旋钮：星星（音量滑块同款贴图）
		draw_sprite_ext(spr_option_volume_slider, 0, _knob, _sy, 0.55, 0.55, 0, c_white, 1);

		// 当前档位名（滑块右侧）
  draw_set_color(c_white);      // 复位颜色（上面盖深色时改成了 #17314C）
		draw_set_halign(fa_left);
		draw_text(x - 80, y + 327, _name);
		draw_set_halign(fa_center);
	    break;
	case 3:
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_middle);
		//draw_text(x - 380, y - 180, "卡片血条");
		//draw_text(x - 380, y - 100, "敌人血条");
		//draw_text(x - 380, y - 20, "难度");
		//draw_text(x - 380, y + 60, "失去焦点时暂停");
		//draw_set_halign(fa_left);
		//draw_set_valign(fa_top);
		draw_sprite(spr_option_menu_text,2,x-120,y+60)
		// 难度等级名：平时静态绘制；切换时旧名向一侧滑出、新名从另一侧滑入，超出卡片内边距的部分裁掉
		if (diff_anim_t < 0 || !ui_anim_on(1)) {   // 等级 0（或动画已结束）静态绘制
			draw_sprite_ext(spr_option_menu_difficulty, global.difficulty, x+15, y+102, 0.2, 0.2, 0, c_white, 1)
		} else {
			var _sc    = 0.2;                                                   // 与静态绘制一致的缩放
			var _sw    = sprite_get_width(spr_option_menu_difficulty);           // 原始像素宽
			var _sh    = sprite_get_height(spr_option_menu_difficulty);          // 原始像素高
			var _ox    = sprite_get_xoffset(spr_option_menu_difficulty) * _sc;   // 原点换算到屏幕
			var _oy    = sprite_get_yoffset(spr_option_menu_difficulty) * _sc;
			var _win   = _sw * _sc + diff_anim_pad * 2;      // 裁剪窗口宽 = 等级名 + 两侧内边距
			var _left0 = x + 15 - _ox;                       // 静止时等级名的视觉左边界
			var _w1    = _left0 - diff_anim_pad;             // 窗口左边界（右边界 = _w1 + _win）
			var _top   = y + 102 - _oy;
			var _p     = diff_anim_t / diff_anim_frames;
			var _e     = 1 - (1 - _p) * (1 - _p) * (1 - _p); // 非线性缓动：ease-out（起步快、收尾慢）
			var _shift = _win * _e;
			var _dxf   = -diff_anim_dir * _shift;            // 旧名的位移
			var _dxt   =  diff_anim_dir * (_win - _shift);   // 新名的位移（dir=1 时自右侧进）
			// 旧名
			var _lft = x + 15 + _dxf - _ox;
			var _vl  = max(_w1, _lft);
			var _vr  = min(_w1 + _win, _lft + _sw * _sc);
			if (_vr > _vl) {
				draw_sprite_part_ext(spr_option_menu_difficulty, diff_anim_from,
					(_vl - _lft) / _sc, 0, (_vr - _vl) / _sc, _sh, _vl, _top, _sc, _sc, c_white, 1);
			}
			// 新名
			_lft = x + 15 + _dxt - _ox;
			_vl  = max(_w1, _lft);
			_vr  = min(_w1 + _win, _lft + _sw * _sc);
			if (_vr > _vl) {
				draw_sprite_part_ext(spr_option_menu_difficulty, diff_shown,
					(_vl - _lft) / _sc, 0, (_vr - _vl) / _sc, _sh, _vl, _top, _sc, _sc, c_white, 1);
			}
		}
		break
    
    // 可以添加其他设置页面
	case 0:
		// 入场动画：音量条从 0 涨到记忆值（只影响显示，不改实际音量）
		var _ease = 1;
		if (global.vol_intro_p >= 0) {
			var _ip = global.vol_intro_p;
			_ease = 1 - (1 - _ip) * (1 - _ip) * (1 - _ip);
		}
		var _mv = global.music_volume * _ease;
		var _sv = global.sound_volume * _ease;
		// 绘制音频设置标签
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_set_color(#9DCFEC);
		
		draw_sprite(spr_option_volume_bg,0,x,y-87)
		// 音乐标签
		//draw_text_ext_transformed(x - 430, y - 155, "音乐",0,900,1,1,0);
		draw_text_ext_transformed(x + 355, y - 148, string(round(_mv * 100)) + "%", 0, 900, 1, 1, 0);

		// 音效标签
		//draw_text_ext_transformed(x - 430, y - 75, "音效",0,900,1,1,0);
		draw_text_ext_transformed(x + 355, y - 50, string(round(_sv * 100)) + "%", 0, 900, 1, 1, 0);

		// 绘制进度条背景
		var bar_height = 20;
		var bar_min_x = x - 280;
		var bar_max_x = x + 280;

		// 音乐进度条
		draw_sprite(spr_option_volume_bar,0,x+2,y-134)
		//draw_set_color(merge_color(c_blue,c_black,0.5));
		//draw_roundrect(bar_min_x, y - 150, bar_max_x, y - 120, false);
		draw_set_color(#17314C);
		draw_roundrect(bar_max_x, y - 150, bar_min_x + (bar_max_x - bar_min_x) * _mv, y - 120, false);

		// 音效进度条
		draw_sprite(spr_option_volume_bar,0,x+2,y-37)
		//draw_set_color(merge_color(c_blue,c_black,0.5));
		//draw_roundrect(bar_min_x, y - 55, bar_max_x, y - 25, false);
		draw_set_color(#17314C);
		draw_roundrect(bar_max_x, y - 55, bar_min_x + (bar_max_x - bar_min_x) * _sv, y - 25, false);
		break;
	case 1:
		// 绘制标签
		draw_set_halign(fa_left);
		draw_set_valign(fa_middle);
		draw_set_color(#9DCFEC);
		//draw_text(x - 350, y - 170, "替换放置");
		//draw_text(x + 50, y - 170, "快速放置");
		//draw_text(x - 420, y - 115, "快捷键设置:");
		draw_sprite(spr_option_menu_text,0,x,y+65)

		// 绘制当前页数
		draw_set_halign(fa_center);
		draw_text(x-65, y + 290, string(keybind_page + 1));
		draw_text(x+65, y + 290, string(total_keybind_pages));
		break;
}

if (_pg_live) {
	surface_reset_target();
	// 视口反向偏移 = 内容正向平移；源矩形探到窗口外的那条透明边就是"滑入"本身
	draw_surface_part_ext(pg_surf, pg_win_l - _pg_shift, pg_win_t, pg_win_w, pg_win_h,
	                      pg_win_l, pg_win_t, 1, 1, c_white, _pg_ease);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);

panel_anim_end_slide(id, 260)