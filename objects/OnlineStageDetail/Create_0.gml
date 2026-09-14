///
self.state = {
    scale: 1.9,
    left: 0,
    top: 0,
    height: 0,
    width: 0,
    /// @type {Struct.OnlineMapItem}
    item: undefined,
    /// @type {function}
    on_close_clicked: undefined,
    /// @type {function}
    on_action: undefined,
    /// @type {Asset.GMObject.Button}
    close_button: undefined,
}

function init(_item) {
    self.state.item = _item
    return self
}

function set_item(_item) {
    self.state.item = _item
    return self
}

function set_position(_left, _top) {
    self.state.left = _left
    self.state.top = _top
    if (!is_undefined(self.state.close_button)) {
        self.state.close_button.set_position(_left + self.state.width - 50, _top + 44)
    }
    return self
}

function get_width() {
    return self.state.width
}

function get_height() {
    return self.state.height
}

function action_rect() {
    return {
        x1: self.state.left + self.state.width - 240,
        y1: self.state.top + self.state.height - 110,
        x2: self.state.left + self.state.width - 40,
        y2: self.state.top + self.state.height - 50,
    }
}

function on_close() {
    if (!is_undefined(self.state.on_close_clicked)) {
        self.state.on_close_clicked()
    }
    if (!is_undefined(self.state.close_button)) {
        instance_destroy(self.state.close_button)
        self.state.close_button = undefined
    }
    instance_destroy()
}

function set_on_close_clicked(_on_close_clicked) {
    self.state.on_close_clicked = _on_close_clicked
    return self
}

function set_on_action(_on_action) {
    self.state.on_action = _on_action
    return self
}

function create_widgets() {
    /// @type {Asset.GMObject.Button}
    var _close_button = instance_create_layer(0, 0, "Float", Button)
    _close_button.set_auto_draw(false)
        .set_sprite(spr_closemenu_btn)
        .set_scale(1.9)
        .set_frames(0, 1, 2)
        .set_on_click(method(self, on_close))
    self.state.close_button = _close_button
}

function on_create() {
    self.state.height = sprite_get_height(spr_stage_detail) * self.state.scale
    self.state.width = sprite_get_width(spr_stage_detail) * self.state.scale
    create_widgets()
}

function on_step() {
    if (is_undefined(self.state.item)) {
        exit
    }
    if (mouse_check_button_released(mb_left)) {
        var _mx = device_mouse_x_to_gui(0)
        var _my = device_mouse_y_to_gui(0)
        var _ar = action_rect()
        if (point_in_rectangle(_mx, _my, _ar.x1, _ar.y1, _ar.x2, _ar.y2)) {
            if (!is_undefined(self.state.on_action)) {
                self.state.on_action(self.state.item)
            }
        }
    }
}

function on_draw() {
    draw_sprite_ext(
        spr_stage_detail, 0,
        self.state.left, self.state.top,
        self.state.scale, self.state.scale,
        0, c_white, 1)

    if (!is_undefined(self.state.close_button)) {
        self.state.close_button.on_draw()
    }

    if (is_undefined(self.state.item)) {
        exit
    }

    var _item = self.state.item
    scribble(_item.title, "online_stage_detail_name")
        .align(fa_center, fa_center)
        .scale(1.2)
        .starting_format("font_hei_outline_4dir_black")
        .draw(self.state.left + (self.state.width / 2), self.state.top + 114)

    scribble(_item.id)
        .draw(self.state.left + 160, self.state.top + 170)
    scribble(_item.author)
        .draw(self.state.left + 130, self.state.top + 228)

    var _desc = string_trim(string(_item.description))
    if (_desc == "") {
        _desc = "无简介"
    }
    var _body = _desc
    if (_item.detail != "") {
        _body += "\n" + _item.detail
    }
    if (_item.difficulty != "") {
        _body += "\n难度：" + _item.difficulty
    }
    if (_item.special_mechanics != "") {
        _body += "\n机制：" + _item.special_mechanics
    }
    scribble(_body, "online_stage_detail_desc")
        .wrap(650, 360)
        .line_spacing("90%")
        .scale(1.0)
        .draw(self.state.left + 50, self.state.top + 300)

    scribble("下载 " + string(_item.downloads))
        .draw(self.state.left + 50, self.state.top + self.state.height - 70)

    var _ar = action_rect()
    var _label = _item.downloaded ? "删除" : "下载"
    draw_set_color(_item.downloaded ? make_color_rgb(168, 72, 64) : make_color_rgb(72, 128, 72))
    draw_roundrect(_ar.x1, _ar.y1, _ar.x2, _ar.y2, false)
    scribble(_label)
        .align(fa_center, fa_middle)
        .starting_format("font_hei_outline_4dir_black")
        .draw((_ar.x1 + _ar.x2) * 0.5, (_ar.y1 + _ar.y2) * 0.5)
}

on_create()
