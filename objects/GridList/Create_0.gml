/// 
self.state = {
    items: [],
    scroll_y: 0,
    scroll_target_y: 0,
    scroll_lerp: 0.2,
    item_spacing: 4,
    viewport_left: 0,
    viewport_top: 0,
    viewport_width: 0,
    viewport_height: 0,
    wheel_step: 10,
    padding_left: 0,
    padding_top: 0,
    padding_bottom: 0,
    content_height: 0,
    row_height: 0,

    grid_x: 3,
    grid_gap: 10,
    scrollbar_width: 14,
    scrollbar_dragging: false,
    scrollbar_drag_offset: 0,
    show_scrollbar: false,

    /// @type {function} 
    should_correspond: function () {return true},

}

/// @description Setup

function set_viewport(_left, _top, _width, _height) {
    self.state.viewport_left = _left
    self.state.viewport_top = _top
    self.state.viewport_width = _width
    self.state.viewport_height = _height
    if (array_length(self.state.items) > 0) {
        self.state.content_height = calculate_content_height()
    }
    clamp_scroll_bounds()
    return self
}

function set_wheel_step(_pixels) {
    self.state.wheel_step = _pixels
    return self
}

/// @param {real} _k
function set_scroll_lerp(_k) {
    self.state.scroll_lerp = clamp(_k, 0.01, 1)
    return self
}

function _require_item_api(_inst, _index) {
    if (!variable_instance_exists(_inst, "get_height")) {
        throw("GridList: items[" + string(_index) + "] missing get_height")
    }
    if (!variable_instance_exists(_inst, "set_position")) {
        throw("GridList: items[" + string(_index) + "] missing set_position")
    }
    if (!variable_instance_exists(_inst, "on_draw")) {
        throw("GridList: items[" + string(_index) + "] missing on_draw")
    }
}

/// @returns {Real} 
function calculate_content_height() {
    var _item_count = array_length(self.state.items)
    if (_item_count == 0) {
        self.state.row_height = 0
        return 0
    }
    var _get_height = variable_instance_get(self.state.items[0], "get_height")
    if (is_undefined(_get_height)) {
        throw("GridList: All items must have a get_height method")
    }

    var _height = method(self.state.items[0], _get_height)()
    self.state.row_height = _height
    var _gx = max(1, self.state.grid_x)
    var _rows = (_item_count + _gx - 1) div _gx

    return _rows * (_height + self.state.grid_gap) - self.state.grid_gap + self.state.padding_top + self.state.padding_bottom 
}

function set_should_correspond(_should_correspond) {
    if (is_undefined(_should_correspond)) {
        throw("GridList: should_correspond must be a function")
    }
    self.state.should_correspond = _should_correspond
    return self
}

function destroy_items() {
    var _n = array_length(self.state.items)
    for (var _i = 0; _i < _n; _i++) {
        var _inst = self.state.items[_i]
        if (!is_undefined(_inst) && instance_exists(_inst)) {
            instance_destroy(_inst)
        }
    }
    self.state.items = []
    self.state.content_height = 0
    self.state.scroll_y = 0
    self.state.scroll_target_y = 0
    return self
}

function set_items(_items) {
    if (self.state.viewport_height == 0 || self.state.viewport_width == 0) {
        throw("GridList: Set viewport first")
    }
    var _n = array_length(_items)
    for (var _i = 0; _i < _n; _i++) {
        var _inst = _items[_i]
        if (is_undefined(_inst) || !instance_exists(_inst)) {
            throw("GridList: items[" + string(_i) + "] is not a valid instance")
        }
        _require_item_api(_inst, _i)
    }
    self.state.items = _items
    self.state.content_height = calculate_content_height()
    clamp_scroll_bounds()
    return self
}

function get_max_scroll() {
    return max(0, self.state.content_height - self.state.viewport_height)
}

function set_grid_x(_x) {
    self.state.grid_x = max(1, _x)
    return self
}

function clamp_scroll_bounds() {
    var _max = get_max_scroll()
    self.state.scroll_target_y = clamp(self.state.scroll_target_y, 0, _max)
    self.state.scroll_y = clamp(self.state.scroll_y, 0, _max)
}

function smooth_scroll_y() {
    clamp_scroll_bounds()
    var _k = self.state.scroll_lerp
    self.state.scroll_y = lerp(self.state.scroll_y, self.state.scroll_target_y, _k)
    if (abs(self.state.scroll_y - self.state.scroll_target_y) < 0.35) {
        self.state.scroll_y = self.state.scroll_target_y
    }
}

/// @description 每帧根据视口与滚动更新子项位置与 visible（窗口坐标 = room 坐标）
function layout_items() {
    var _n = array_length(self.state.items)
    if (_n == 0) {
        return
    }

    var _gx = max(1, self.state.grid_x)
    var _gap = self.state.grid_gap
    var _vleft = self.state.viewport_left
    var _vtop = self.state.viewport_top
    var _vw = self.state.viewport_width
    var _vh = self.state.viewport_height
    var _vright = _vleft + _vw
    var _vbottom = _vtop + _vh
    var _pleft = self.state.padding_left
    var _ptop = self.state.padding_top
    var _scroll = self.state.scroll_y

    var _inner_w = _vw - _pleft - (_gx - 1) * _gap
    var _cell_w = _inner_w / _gx
    var _row_h = self.state.row_height
    if (_row_h <= 0) {
        var _gh = variable_instance_get(self.state.items[0], "get_height")
        if (!is_undefined(_gh)) {
            _row_h = method(self.state.items[0], _gh)()
        }
    }
    var _row_stride = _row_h + _gap

    for (var i = 0; i < _n; i++) {
        var inst = self.state.items[i]
        if (is_undefined(inst) || !instance_exists(inst)) {
            continue
        }

        var _col = i mod _gx
        var _row = i div _gx
        var _x = _vleft + _pleft + _col * (_cell_w + _gap)
        var _y = _vtop + _ptop + _row * _row_stride - _scroll

        var _cell_right = _x + _cell_w
        var _cell_bottom = _y + _row_h
        var _in_view = !(_cell_right <= _vleft || _x >= _vright || _cell_bottom <= _vtop || _y >= _vbottom)

        var _set_position = variable_instance_get(inst, "set_position")
        if (is_undefined(_set_position)) {
            throw("GridList: item missing set_position")
        }
        method(inst, _set_position)(_x, _y)
        variable_instance_set(inst, "visible", _in_view)
    }
}

function is_mouse_over_viewport() {
    var _mx = device_mouse_x(0)
    var _my = device_mouse_y(0)
    return point_in_rectangle(
        _mx, _my,
        self.state.viewport_left, self.state.viewport_top,
        self.state.viewport_left + self.state.viewport_width, self.state.viewport_top + self.state.viewport_height
    )
}

function scrollbar_needed() {
    return self.state.show_scrollbar && get_max_scroll() > 0
}

function get_scrollbar_metrics() {
    var _track_x = self.state.viewport_left + self.state.viewport_width - self.state.scrollbar_width
    var _track_y = self.state.viewport_top
    var _track_w = self.state.scrollbar_width
    var _track_h = self.state.viewport_height
    var _max = get_max_scroll()
    var _ratio = (_max <= 0) ? 1 : clamp(self.state.viewport_height / self.state.content_height, 0.12, 1)
    var _thumb_h = max(28, _track_h * _ratio)
    var _thumb_y = _track_y
    if (_max > 0) {
        _thumb_y = _track_y + (self.state.scroll_y / _max) * (_track_h - _thumb_h)
    }
    return {
        track_x: _track_x,
        track_y: _track_y,
        track_w: _track_w,
        track_h: _track_h,
        thumb_x: _track_x,
        thumb_y: _thumb_y,
        thumb_w: _track_w,
        thumb_h: _thumb_h,
    }
}

function is_mouse_over_scrollbar() {
    if (!scrollbar_needed()) {
        return false
    }
    var _m = get_scrollbar_metrics()
    var _mx = device_mouse_x(0)
    var _my = device_mouse_y(0)
    return point_in_rectangle(_mx, _my, _m.track_x, _m.track_y, _m.track_x + _m.track_w, _m.track_y + _m.track_h)
}

function apply_scrollbar_input() {
    if (!scrollbar_needed()) {
        self.state.scrollbar_dragging = false
        return
    }
    var _m = get_scrollbar_metrics()
    var _mx = device_mouse_x(0)
    var _my = device_mouse_y(0)
    var _over_track = point_in_rectangle(_mx, _my, _m.track_x, _m.track_y, _m.track_x + _m.track_w, _m.track_y + _m.track_h)
    var _over_thumb = point_in_rectangle(_mx, _my, _m.thumb_x, _m.thumb_y, _m.thumb_x + _m.thumb_w, _m.thumb_y + _m.thumb_h)

    if (mouse_check_button_pressed(mb_left) && _over_track) {
        if (_over_thumb) {
            self.state.scrollbar_dragging = true
            self.state.scrollbar_drag_offset = _my - _m.thumb_y
        } else {
            var _max = get_max_scroll()
            var _travel = max(1, _m.track_h - _m.thumb_h)
            self.state.scroll_target_y = clamp((_my - _m.track_y - _m.thumb_h * 0.5) / _travel * _max, 0, _max)
        }
    }

    if (self.state.scrollbar_dragging) {
        if (mouse_check_button(mb_left)) {
            var _max = get_max_scroll()
            var _travel = max(1, _m.track_h - _m.thumb_h)
            var _thumb_y = clamp(_my - self.state.scrollbar_drag_offset, _m.track_y, _m.track_y + _travel)
            self.state.scroll_target_y = ((_thumb_y - _m.track_y) / _travel) * _max
            self.state.scroll_y = self.state.scroll_target_y
        } else {
            self.state.scrollbar_dragging = false
        }
    }
}

function draw_scrollbar() {
    if (!scrollbar_needed()) {
        return
    }
    var _m = get_scrollbar_metrics()
    draw_set_alpha(0.35)
    draw_set_color(make_color_rgb(70, 52, 36))
    draw_roundrect(_m.track_x, _m.track_y, _m.track_x + _m.track_w, _m.track_y + _m.track_h, false)
    draw_set_alpha(0.85)
    draw_set_color(make_color_rgb(210, 176, 120))
    draw_roundrect(_m.thumb_x, _m.thumb_y, _m.thumb_x + _m.thumb_w, _m.thumb_y + _m.thumb_h, false)
    draw_set_alpha(1)
    draw_set_color(c_white)
}

function apply_wheel() {
    if (!is_mouse_over_viewport()) {
        return
    }
    if (mouse_wheel_up()) {
        self.state.scroll_target_y -= self.state.wheel_step
    }
    if (mouse_wheel_down()) {
        self.state.scroll_target_y += self.state.wheel_step
    }
    clamp_scroll_bounds()
}

/// @description Begin Step — layout + scroll before child Step
function on_begin_step() {
    if (!self.state.should_correspond()) {
        exit
    }
    apply_scrollbar_input()
    apply_wheel()
    smooth_scroll_y()
    layout_items()
}

/// @description Draw：视口裁剪后绘制子项

function on_draw() {
    var _item_count = array_length(self.state.items)
    if (_item_count == 0) {
        draw_scrollbar()
        return
    }

    var _prev_scissor = gpu_get_scissor()
    gpu_set_scissor(
        floor(self.state.viewport_left),
        floor(self.state.viewport_top),
        floor(self.state.viewport_width),
        floor(self.state.viewport_height)
    )

    for (var i = 0; i < _item_count; i++) {
        var inst = self.state.items[i]
        if (is_undefined(inst) || !instance_exists(inst)) {
            continue
        }
        if (!inst.visible) {
            continue
        }
        if (variable_instance_get(inst, "auto_draw") == false) {
            continue
        }

        var _on_draw = variable_instance_get(inst, "on_draw")
        if (!is_undefined(_on_draw)) {
            method(inst, _on_draw)()
        }
    }

    gpu_set_scissor(_prev_scissor)
    draw_scrollbar()
}

