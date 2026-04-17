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

    /// @type {Array<Asset.GMRoom>} 
    correspond_rooms: [room_laboratory],

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
    if (!variable_instance_exists(_inst, "on_draw_gui")) {
        throw("GridList: items[" + string(_index) + "] missing on_draw_gui")
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

/// @param {Array<Asset.GMRoom>} _rooms 
function set_correspond_rooms(_rooms) {
    self.state.correspond_rooms = _rooms
    return self
}

function should_correspond() {
    var _current = global.gui_stack.get_top()
    if (is_undefined(_current)) {
        return true
    }
    if (array_contains(self.state.correspond_rooms, _current)) {
        return true
    }
    return false
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
    var _mx = device_mouse_x_to_gui(0)
    var _my = device_mouse_y_to_gui(0)
    return point_in_rectangle(
        _mx, _my,
        self.state.viewport_left, self.state.viewport_top,
        self.state.viewport_left + self.state.viewport_width, self.state.viewport_top + self.state.viewport_height
    )
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
    if (!should_correspond()) {
        exit
    }
    apply_wheel()
    smooth_scroll_y()
    layout_items()
}

/// @description 未使用 Draw 事件；保留空实现

function on_draw() {
}

/// @description Draw GUI

function on_draw_gui() {
    var _item_count = array_length(self.state.items)
    if (_item_count == 0) {
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

        var _on_draw_gui = variable_instance_get(inst, "on_draw_gui")
        if (!is_undefined(_on_draw_gui)) {
            method(inst, _on_draw_gui)()
        }
    }

    gpu_set_scissor(_prev_scissor)
}

