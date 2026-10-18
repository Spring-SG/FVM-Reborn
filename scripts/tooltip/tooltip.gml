// ══════════════════════════════════════════════════════════════════════
// 通用悬浮提示框（tooltip）：尺寸非线性过渡 + 消失宽限 + 缩小消失
// 每个实例各持一份，任何 Draw 事件里这样用：
//     if (悬停成立) tooltip_set(_x, _y, _文本, _方向);   // +1 = 框在锚点右侧；-1 = 左侧
//     tooltip_draw();                                    // 该 Draw 事件末尾调一次
// 速率与宽限参数在 Tooltip 构造函数里。
// ══════════════════════════════════════════════════════════════════════
function Tooltip() constructor {
    self.anim_w = 0; self.anim_h = 0;         // 当前显示的框尺寸
    self.anim_tw = -1; self.anim_th = -1;     // 目标尺寸（-1 = 没有内容）
    self.speed = 0.06;                        // 本段过渡的当前速率（逐帧爬升 → 起步缓慢、后段加快）
    self.speed_start = 0.06;
    self.speed_step  = 0.05;
    self.speed_max   = 0.40;
    self.text = ""; self.tx = 0; self.ty = 0; self.dir = 1; self.font = -1;
    self.showing = false;                     // 本帧有没有命中
    self.stamp = -1;                          // 上次 set() 的时刻（微秒，get_timer）；用来判断本帧有没有人调 set
    self.hold = 0; self.hold_frames = 3;      // 0.05s @60fps：扫过空隙不闪，也决定消失前等多久
    self.out_t = -1;                          // 消失进度（-1 = 没在消失）
    self.box_alpha = 0.7;                     // 提示框底色的不透明度（各面板原值不同，按调用点指定）
    self.fill_col = c_black;                  // 底色
    self.border_col = -1;                     // 描边色（-1 = 不描边）
    self.text_col = c_white;                  // 文字色

    /// @param {Real} _dir +1 = 框在锚点右侧；-1 = 框在锚点左侧
    static set = function(_x, _y, _text, _dir, _box_alpha, _style, _gen) {
        self.box_alpha = _box_alpha;
        self.gen = _gen;
        if (is_undefined(_style)) {
            self.fill_col = c_black; self.border_col = -1; self.text_col = c_white;
        } else {
            self.fill_col = _style.fill; self.border_col = _style.border; self.text_col = _style.text_col;
        }
        self.tx = _x; self.ty = _y; self.dir = _dir;
        if (_text != self.text) {
            self.text = _text;
            self.font = draw_get_font();
        }
        self.showing = true;
        self.stamp = get_timer();
        self.hold = 0;
        self.out_t = -1;
        var _pf = draw_get_font();
        draw_set_font(self.font);
        var _lines = string_split(_text, "\n");
        var _tw = 0;
        var _th = 0;
        for (var _i = 0; _i < array_length(_lines); _i++) {
            var _ln = _lines[_i];
            if (_ln == "") _ln = " ";
            _tw = max(_tw, string_width(_ln));
            _th += string_height(_ln);
        }
        _tw = _tw + 10;
        _th = _th + 10;
        draw_set_font(_pf);
        if (_tw != self.anim_tw || _th != self.anim_th) self.speed = self.speed_start;
        self.anim_tw = _tw;
        self.anim_th = _th;
    };

    static draw = function() {
        // 超时未 set 视为不显示：showing 只在 set 时置真，没有超时判定会永久停在 true
        // 时间戳用 get_timer()（微秒、纯函数），不能用 current_frame —— 构造函数里读内置实例变量
        // 会报 "Variable Tooltip.current_frame not set before reading it"
        // 同一帧只允许一个提示框：别处已 set 过就收掉自己，不绘制
        self.showing = (self.stamp >= 0 && get_timer() - self.stamp < 8000);
        if (!variable_global_exists("tt_gen") || self.gen != global.tt_gen) {
            self.anim_w = 0; self.anim_h = 0;
            self.anim_tw = -1; self.anim_th = -1;
            self.text = ""; self.out_t = -1; self.showing = false; self.hold = 0;
            return;
        }
        if (!ui_anim_on(2)) {                             // 动效等级 <2：瞬显瞬消（不做尺寸过渡/容器揭示/淡出）
            if (self.anim_tw >= 0) { self.anim_w = self.anim_tw; self.anim_h = self.anim_th; }
            if (!self.showing) {
                self.hold++;
                if (self.hold > self.hold_frames) {
                    self.anim_w = 0; self.anim_h = 0;
                    self.anim_tw = -1; self.anim_th = -1;
                    self.text = ""; self.out_t = -1; self.speed = self.speed_start;
                }
            }
        } else if (!self.showing) {                       // 这一帧没命中
            self.hold++;
            if (self.hold > self.hold_frames && self.out_t < 0 && self.anim_tw >= 0) {
                self.out_t = 0;                           // 宽限结束 → 缩小消失
                self.speed = self.speed_start;
            }
        }
        if (self.anim_tw >= 0) {
            if (self.showing || self.out_t >= 0) {
                // 尺寸按每帧逼近目标推进（放大、缩小、消失共用一条路径）；没有计时器，因此不会一步到位
                self.speed = min(self.speed_max, self.speed + self.speed_step);
                if (self.out_t >= 0) {
                    self.out_t++;
                    self.anim_w -= self.anim_w * self.speed;          // 消失：朝锚点收成 0
                    self.anim_h -= self.anim_h * self.speed;
                    if (self.anim_w <= 1.5 || self.anim_h <= 1.5 || self.out_t > 120) {
                        self.out_t = -1; self.anim_w = 0; self.anim_h = 0;
                        self.anim_tw = -1; self.anim_th = -1; self.text = ""; self.speed = self.speed_start;
                    }
                } else {
                    self.anim_w += (self.anim_tw - self.anim_w) * self.speed;
                    self.anim_h += (self.anim_th - self.anim_h) * self.speed;
                    if (abs(self.anim_tw - self.anim_w) < 0.5 && abs(self.anim_th - self.anim_h) < 0.5) {
                        self.anim_w = self.anim_tw; self.anim_h = self.anim_th;
                    }
                }
            }
        } else {
            self.anim_w = 0; self.anim_h = 0;
        }

        if (self.anim_tw >= 0 && self.text != "" && self.anim_w > 2) {
            var _prev_font = draw_get_font();
            draw_set_font(self.font);

            // 文字先于容器出现：揭示宽度 = 容器当前宽度 + 剩余差距的 30%（约 0.2 秒到达）
            var _lead = 0.30;
            var _rw = self.anim_w;
            var _rh = self.anim_h;
            if (self.out_t < 0 && self.anim_tw >= 0) {
                _rw = self.anim_w + (self.anim_tw - self.anim_w) * _lead;
                _rh = self.anim_h + (self.anim_th - self.anim_h) * _lead;
            }
            // 容器绘制宽度恒不小于文字，所以文字不可能露出容器外
            var _draw_w = max(self.anim_w, _rw);
            var _draw_h = max(self.anim_h, _rh);

            // 容器
            var _by1 = self.ty - 5;
            var _by2 = self.ty - 5 + _draw_h;
            var _bx1, _bx2;
            if (self.dir > 0)      { _bx1 = self.tx - 5;              _bx2 = self.tx - 5 + _draw_w; }
            else if (self.dir < 0) { _bx1 = self.tx + 5 - _draw_w;     _bx2 = self.tx + 5; }
            else                   { _bx1 = self.tx - _draw_w / 2;     _bx2 = self.tx + _draw_w / 2; }
            draw_set_halign(fa_left);            // 必须显式复位：调用者可能设成居中/中缝
            draw_set_valign(fa_top);             // （框是矩形不受影响，但逐字绘制会整体错位）
            draw_set_color(self.fill_col);
            draw_set_alpha(self.box_alpha);
            draw_rectangle(_bx1, _by1, _bx2, _by2, false);
            if (self.border_col != -1) {
                draw_set_color(self.border_col);
                draw_set_alpha(1);
                draw_rectangle(_bx1, _by1, _bx2, _by2, true);
            }

            // 文字按已画出的容器矩形裁剪：容器覆盖多少就画多少，结构上不会溢出
            draw_set_color(self.text_col);
            draw_set_alpha(1);
            var _lines = string_split(self.text, "\n");
            // 揭示范围按实际画出的框计算（而非提前量），文字与容器边界始终一致
            var _avail_h = _draw_h - 8;
            var _block_w = max(1, self.anim_tw - 10);          // 多行文字按整块对齐（各行左端对齐）
            var _yy = self.ty;
            for (var _i = 0; _i < array_length(_lines); _i++) {
                var _ln = _lines[_i];
                var _lh = string_height(_ln);
                if (_lh < 1) _lh = string_height(" ");
                if (_yy + _lh > self.ty + _avail_h) break;          // 容器还没长到这一行 → 后面的都不画
                // 文字保持最终位置（不随容器尺寸挪动），只画被容器覆盖的部分
                // 整块文字在框内的位置由框矩形决定：框够宽时右端贴内右沿，
                // 不够宽时贴内左沿（右侧不足处等框长过来）
                var _inner_l = _bx1 + 5;
                var _inner_r = _bx2 - 5;
                var _x0;
                if (self.dir > 0)      { _x0 = _inner_l; }
                else if (self.dir < 0) { _x0 = max(_inner_l, _inner_r - _block_w); }
                else                   { _x0 = max(_inner_l, _inner_l + (_inner_r - _inner_l - _block_w) / 2); }
                var _limit_l = _inner_l;
                var _limit_r = _inner_r;
                var _pen = _x0;
                for (var _k = 1; _k <= string_length(_ln); _k++) {
                    var _ch = string_char_at(_ln, _k);
                    var _cw = string_width(_ch);
                    if (_pen + _cw > _limit_r) break;                      // 超出框右沿 → 后面的字不画
                    if (_pen >= _limit_l) draw_text(_pen, _yy, _ch);       // 只画框已经盖住的那部分
                    _pen += _cw;
                }

                _yy += _lh;
            }
            draw_set_font(_prev_font);
        }
        draw_set_alpha(1);
        self.showing = false;                             // 下一帧重新判定命中
    };
}

/// @function tooltip_set(_x, _y, _text, _dir)
/// @description 当前实例的提示框：记录要显示的内容并设定目标尺寸（不绘制）。
function tooltip_set(_x, _y, _text, _dir) {
    // 第 5 个参数（可选）= 框底色的不透明度；第 6 个（可选）= 槽位（同一实例的第二个 Draw 事件用 1）
    var _a    = (argument_count >= 5) ? argument[4] : 0.7;
    var _slot = (argument_count >= 6) ? argument[5] : 0;
    var _style = (argument_count >= 7) ? argument[6] : undefined;
    // 谁最后 set，谁就是本帧唯一的提示框（别的会在自己的 draw 里立刻收掉）
    global.tt_gen = variable_global_exists("tt_gen") ? global.tt_gen + 1 : 1;
    if (_slot == 1) {
        if (!variable_instance_exists(id, "__tooltip_b")) __tooltip_b = new Tooltip();
        __tooltip_b.set(_x, _y, _text, _dir, _a, _style, global.tt_gen);
    } else {
        if (!variable_instance_exists(id, "__tooltip")) __tooltip = new Tooltip();
        __tooltip.set(_x, _y, _text, _dir, _a, _style, global.tt_gen);
    }
}

/// @function tooltip_draw()
/// @description 当前实例的提示框：推进动画并绘制。在该 Draw 事件末尾调一次。
function tooltip_draw() {
    var _slot = (argument_count >= 1) ? argument[0] : 0;
    if (_slot == 1) {
        if (variable_instance_exists(id, "__tooltip_b")) __tooltip_b.draw();
    } else {
        if (variable_instance_exists(id, "__tooltip")) __tooltip.draw();
    }
}
