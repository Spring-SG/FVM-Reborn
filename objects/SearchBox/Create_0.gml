///
self.state = {
    left: 0,
    top: 0,
    width: 420,
    height: 40,
    text: "",
    placeholder: "搜索名称或作者",
    focused: false,
    cursor_visible: true,
    cursor_timer: 0,
    /// @type {function}
    on_change: undefined,
    /// @type {function ():Bool}
    should_correspond: function() { return true },
}

function set_position(_left, _top) {
    self.state.left = _left
    self.state.top = _top
    return self
}

function set_size(_width, _height) {
    self.state.width = _width
    self.state.height = _height
    return self
}

function set_placeholder(_text) {
    self.state.placeholder = _text
    return self
}

function set_on_change(_on_change) {
    self.state.on_change = _on_change
    return self
}

function set_should_correspond(_should_correspond) {
    if (is_undefined(_should_correspond)) {
        throw("SearchBox: should_correspond must be a function")
    }
    self.state.should_correspond = _should_correspond
    return self
}

function get_text() {
    return self.state.text
}

function set_text(_text) {
    self.state.text = string(_text)
    return self
}

function emit_change() {
    if (!is_undefined(self.state.on_change)) {
        self.state.on_change(self.state.text)
    }
}

function focus() {
    if (self.state.focused) {
        return
    }
    self.state.focused = true
    keyboard_string = self.state.text
    if (variable_global_exists("ime_block") && native_enable_ime != undefined) {
        native_enable_ime(window_handle())
    }
}

function blur() {
    if (!self.state.focused) {
        return
    }
    self.state.focused = false
    if (variable_global_exists("ime_block") && global.ime_block && native_disable_ime != undefined) {
        native_disable_ime(window_handle())
    }
}

function contains_point(_mx, _my) {
    return point_in_rectangle(
        _mx, _my,
        self.state.left, self.state.top,
        self.state.left + self.state.width,
        self.state.top + self.state.height)
}

function on_create() {
}

function on_step() {
    if (!visible) {
        exit
    }
    if (!self.state.should_correspond()) {
        if (self.state.focused) {
            blur()
        }
        exit
    }

    if (mouse_check_button_pressed(mb_left)) {
        var _mx = device_mouse_x_to_gui(0)
        var _my = device_mouse_y_to_gui(0)
        if (contains_point(_mx, _my)) {
            focus()
        } else if (self.state.focused) {
            blur()
        }
    }

    if (!self.state.focused) {
        exit
    }

    if (keyboard_check_pressed(vk_escape)) {
        blur()
        exit
    }

    var _prev = self.state.text
    if (keyboard_check(vk_control) && keyboard_check_pressed(ord("V"))) {
        self.state.text += clipboard_get_text()
        keyboard_string = self.state.text
    } else {
        self.state.text = keyboard_string
    }

    if (string_length(self.state.text) > 64) {
        self.state.text = string_copy(self.state.text, 1, 64)
        keyboard_string = self.state.text
    }

    if (self.state.text != _prev) {
        emit_change()
    }

    self.state.cursor_timer += 1
    if (self.state.cursor_timer >= 30) {
        self.state.cursor_timer = 0
        self.state.cursor_visible = !self.state.cursor_visible
    }
}

function on_draw() {
    if (!visible) {
        exit
    }
    var _s = self.state
    draw_set_alpha(0.72)
    draw_set_color(_s.focused ? make_color_rgb(250, 246, 230) : make_color_rgb(236, 228, 208))
    draw_roundrect(_s.left, _s.top, _s.left + _s.width, _s.top + _s.height, false)
    draw_set_alpha(1)
    draw_set_color(_s.focused ? make_color_rgb(120, 82, 40) : make_color_rgb(90, 72, 48))
    draw_roundrect(_s.left, _s.top, _s.left + _s.width, _s.top + _s.height, true)

    var _label = _s.text
    var _color_name = "font_hei_outline_4dir_black"
    if (_label == "") {
        scribble(_s.placeholder)
            .align(fa_left, fa_middle)
            .starting_format(_color_name)
            .blend(c_gray, 1)
            .draw(_s.left + 12, _s.top + _s.height * 0.5)
    } else {
        scribble(_label)
            .align(fa_left, fa_middle)
            .starting_format(_color_name)
            .draw(_s.left + 12, _s.top + _s.height * 0.5)
        if (_s.focused && _s.cursor_visible) {
            var _tw = string_width(_label)
            draw_set_color(c_black)
            draw_line(_s.left + 14 + _tw, _s.top + 8, _s.left + 14 + _tw, _s.top + _s.height - 8)
        }
    }
}

on_create()
