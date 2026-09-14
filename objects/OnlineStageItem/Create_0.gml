///
self.state = {
    left: 0,
    top: 0,
    height: 0,
    width: 0,
    initialized: false,
    auto_draw: false,
    scale: 1.8,
    /// @type {Struct.OnlineMapItem}
    item: undefined,
    /// @type {function}
    on_click: undefined,
    /// @type {function}
    on_action: undefined,
    /// @type {function ():Bool}
    should_correspond: function() { return true },
    mouse_status: MouseStatus.NONE,
    map_sprite_left: 16,
    map_sprite_top: 65,
    map_sprite_scale: 1,
    map_sprite_size: 120,
    action_hover: false,
}

function set_position(_left, _top) {
    self.state.left = _left
    self.state.top = _top
    self.x = _left
    self.y = _top
    return self
}

function get_height() {
    return self.state.height
}

function refresh_thumb_scale(_sprite) {
    self.state.map_sprite_scale = 1
    if (is_undefined(_sprite) || !sprite_exists(_sprite)) {
        return
    }
    var _h = sprite_get_height(_sprite)
    if (_h > 0) {
        self.state.map_sprite_scale = self.state.map_sprite_size / _h
    }
}

function init(_item) {
    self.state.item = _item
    self.state.initialized = true
    if (!is_undefined(_item.thumb_sprite)) {
        refresh_thumb_scale(_item.thumb_sprite)
    }
    return self
}

function set_thumb_sprite(_sprite) {
    if (is_undefined(self.state.item)) {
        return self
    }
    self.state.item.thumb_sprite = _sprite
    refresh_thumb_scale(_sprite)
    return self
}

/// @param {Asset.GMSprite} _sprite
/// @param {Real} _x
/// @param {Real} _y
function draw_map_preview(_sprite, _x, _y) {
    var _box = self.state.map_sprite_size
    var _sw = sprite_get_width(_sprite)
    var _sh = sprite_get_height(_sprite)
    if (_sw <= 0 || _sh <= 0) {
        return
    }
    var _scale = _box / _sh
    var _src_w = min(_sw, _box / _scale)
    var _src_h = min(_sh, _box / _scale)
    self.state.map_sprite_scale = _scale
    draw_sprite_part_ext(_sprite, 0, 0, 0, _src_w, _src_h, _x, _y, _scale, _scale, c_white, 1)
}

function set_downloaded(_downloaded) {
    if (!is_undefined(self.state.item)) {
        self.state.item.downloaded = _downloaded
    }
    return self
}

function set_on_click(_on_click) {
    self.state.on_click = _on_click
    return self
}

function set_on_action(_on_action) {
    self.state.on_action = _on_action
    return self
}

function set_should_correspond(_should_correspond) {
    if (is_undefined(_should_correspond)) {
        throw("should_correspond should not be undefined")
    }
    self.state.should_correspond = _should_correspond
    return self
}

function action_rect() {
    return {
        x1: self.state.left + self.state.width - 118,
        y1: self.state.top + self.state.height - 52,
        x2: self.state.left + self.state.width - 14,
        y2: self.state.top + self.state.height - 16,
    }
}

function update_mouse() {
    var _s = self.state
    var _mx = device_mouse_x_to_gui(0)
    var _my = device_mouse_y_to_gui(0)
    var _in_bound = point_in_rectangle(_mx, _my, _s.left, _s.top, _s.left + _s.width, _s.top + _s.height)
    var _ar = action_rect()
    _s.action_hover = point_in_rectangle(_mx, _my, _ar.x1, _ar.y1, _ar.x2, _ar.y2)
    var _old = _s.mouse_status
    if (!_in_bound) {
        _s.mouse_status = MouseStatus.NONE
    } else if (mouse_check_button(mb_left)) {
        _s.mouse_status = MouseStatus.PRESS
    } else if (_old == MouseStatus.PRESS) {
        _s.mouse_status = MouseStatus.RELEASE
        if (_s.action_hover) {
            if (!is_undefined(_s.on_action)) _s.on_action(_s.item)
        } else if (!is_undefined(_s.on_click)) {
            _s.on_click(_s.item)
        }
    } else {
        _s.mouse_status = MouseStatus.HOVER
    }
}

function on_create() {
    self.state.width = sprite_get_width(spr_stage_item) * self.state.scale
    self.state.height = sprite_get_height(spr_stage_item) * self.state.scale
}

function on_step() {
    if (!self.state.initialized) exit
    if (!visible) exit
    if (!self.state.should_correspond()) exit
    update_mouse()
}

function on_draw() {
    if (!self.state.initialized) exit
    if (is_undefined(self.state.item)) exit

    draw_sprite_ext(spr_stage_item, 0, self.x, self.y, self.state.scale, self.state.scale, 0, c_white, 1)

    var _sprite_start_x = self.state.left + self.state.map_sprite_left
    var _sprite_start_y = self.state.top + self.state.map_sprite_top
    var _box = self.state.map_sprite_size
    var _prev_scissor = gpu_get_scissor()
    var _prev_scissor_top = _prev_scissor.y
    var _prev_scissor_bottom = _prev_scissor.y + _prev_scissor.h
    var _outlined_y = max((_sprite_start_y + _box) - _prev_scissor_bottom, 0)
    var _clip_h = max(0, _box - _outlined_y)
    if (_clip_h > 0) {
        gpu_set_scissor(
            floor(_sprite_start_x),
            floor(max(_prev_scissor_top, _sprite_start_y)),
            ceil(_box),
            ceil(_clip_h))
        if (!is_undefined(self.state.item.thumb_sprite) && sprite_exists(self.state.item.thumb_sprite)) {
            draw_map_preview(self.state.item.thumb_sprite, _sprite_start_x, _sprite_start_y)
        } else {
            draw_set_color(make_color_rgb(180, 160, 130))
            draw_rectangle(_sprite_start_x, _sprite_start_y, _sprite_start_x + _box, _sprite_start_y + _box, false)
        }
        gpu_set_scissor(_prev_scissor)
    }

    scribble(self.state.item.title)
        .align(fa_left, fa_center)
        .starting_format("font_hei_outline_4dir_black")
        .draw(self.state.left + 30, self.state.top + 36)
    scribble(self.state.item.author)
        .align(fa_left, fa_center)
        .draw(self.state.left + 154, self.state.top + 78)
    scribble(self.state.item.description)
        .wrap(330, 80)
        .line_spacing("90%")
        .scale(0.82)
        .draw(self.state.left + 156, self.state.top + 115)

    var _ar = action_rect()
    var _label = self.state.item.downloaded ? "删除" : "下载"
    var _col = self.state.item.downloaded ? make_color_rgb(168, 72, 64) : make_color_rgb(72, 128, 72)
    if (self.state.action_hover) {
        _col = merge_color(_col, c_white, 0.2)
    }
    draw_set_color(_col)
    draw_roundrect(_ar.x1, _ar.y1, _ar.x2, _ar.y2, false)
    scribble(_label)
        .align(fa_center, fa_middle)
        .starting_format("font_hei_outline_4dir_black")
        .draw((_ar.x1 + _ar.x2) * 0.5, (_ar.y1 + _ar.y2) * 0.5)
}

on_create()
