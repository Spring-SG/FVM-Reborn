/// 
self.state = {
    /// @type {Asset.GMSprite} 
    sprite: -1,
    /// offset 为精灵原点（origin）在 GUI 上的坐标，与 draw_sprite_ext 一致；热区按整图外接矩形并抵消 sprite 锚点。
    offset_x: 0,
    offset_y: 0,
    scale: 1,
    sprite_offset_x: 0,
    sprite_offset_y: 0,

    frame_idle: 0,
    frame_hover: 0,
    frame_press: 0,
    current_subimage: 0,

    corresponding_area_l: 0,
    corresponding_area_r: 0,
    corresponding_area_t: 0,
    corresponding_area_b: 0,

    /// @type {Enum.MouseStatus} 
    mouse_status: MouseStatus.NONE,
    click_armed: false,

    /// @type {function} 
    on_click: undefined,
    auto_draw: true,
    /// @type {function} 
    should_correspond: function(){return true},

}


function refresh_hitbox() {
    var _spr = self.state.sprite
    if (!sprite_exists(_spr)) {
        self.state.corresponding_area_l = 0
        self.state.corresponding_area_t = 0
        self.state.corresponding_area_r = 0
        self.state.corresponding_area_b = 0
        return
    }
    var _s = self.state.scale
    var _origin_x = self.state.offset_x + self.state.sprite_offset_x * _s
    var _origin_y = self.state.offset_y + self.state.sprite_offset_y * _s
    var _xo = sprite_get_xoffset(_spr)
    var _yo = sprite_get_yoffset(_spr)
    var _w = sprite_get_width(_spr) * _s
    var _h = sprite_get_height(_spr) * _s
    var _l = _origin_x - _xo * _s
    var _t = _origin_y - _yo * _s
    self.state.corresponding_area_l = _l
    self.state.corresponding_area_t = _t
    self.state.corresponding_area_r = _l + _w
    self.state.corresponding_area_b = _t + _h
}


/// @param {Asset.GMSprite} _sprite 
/// @returns {Asset.GMObject.Button} 
function set_sprite(_sprite) {
    self.state.sprite = _sprite
    refresh_hitbox()
    return self
}

/// @param {Real} _scale 
/// @returns {Asset.GMObject.Button} 
function set_scale(_scale) {
    self.state.scale = _scale
    refresh_hitbox()
    return self
}

/// @param {Real} _left 精灵原点 GUI X（与 draw_sprite_ext 一致，非贴图左上角）
/// @param {Real} _top 精灵原点 GUI Y
/// @returns {Asset.GMObject.Button} 
function set_position(_left, _top) {
    self.state.offset_x = _left
    self.state.offset_y = _top
    refresh_hitbox()
    return self
}

/// @param {Real} _ox 
/// @param {Real} _oy 
/// @returns {Asset.GMObject.Button} 
function set_sprite_offset(_ox, _oy) {
    self.state.sprite_offset_x = _ox
    self.state.sprite_offset_y = _oy
    refresh_hitbox()
    return self
}

/// @param {Real} _idle
/// @param {Real} _hover
/// @param {Real} _press
/// @returns {Asset.GMObject.Button} 
function set_frames(_idle = 0, _hover = 0, _press = 0) {
    self.state.frame_idle = _idle
    self.state.frame_hover = _hover
    self.state.frame_press = _press
    return self
}

/// @param {Real} _frame 
/// @returns {Asset.GMObject.Button} 
function set_frame_idle(_frame) {
    self.state.frame_idle = _frame
    return self
}

/// @param {Real} _frame 
/// @returns {Asset.GMObject.Button} 
function set_frame_hover(_frame) {
    self.state.frame_hover = _frame
    return self
}

/// @param {Real} _frame 
/// @returns {Asset.GMObject.Button} 
function set_frame_press(_frame) {
    self.state.frame_press = _frame
    return self
}

/// @returns {Asset.GMObject.Button} 
function set_auto_draw(_auto_draw) {
    self.state.auto_draw = _auto_draw
    return self
}

/// @param {Function ():Bool} _on_click 
/// @returns {Asset.GMObject.Button} 
function set_on_click(_on_click) {
    self.state.on_click = _on_click
    return self
}

/// @param {function} _should_correspond 
function set_should_correspond(_should_correspond) {
    if (is_undefined(_should_correspond)) {
        throw("should_correspond should not be undefined")
    }
    self.state.should_correspond = _should_correspond
    return self
}

function on_create() {
}

function on_step() {
    if (!self.state.should_correspond()) exit
    if (!sprite_exists(self.state.sprite)) exit

    var _mx = device_mouse_x_to_gui(0)
    var _my = device_mouse_y_to_gui(0)
    var _l = self.state.corresponding_area_l
    var _t = self.state.corresponding_area_t
    var _r = self.state.corresponding_area_r
    var _b = self.state.corresponding_area_b
    var _over = point_in_rectangle(_mx, _my, _l, _t, _r, _b)

    if (!_over) {
        if (self.state.mouse_status != MouseStatus.NONE) {
            window_set_cursor(cr_arrow)
        }
        self.state.mouse_status = MouseStatus.NONE
    } else if (mouse_check_button(mb_left)) {
        if (self.state.mouse_status != MouseStatus.PRESS) {
            window_set_cursor(cr_drag)
        }
        self.state.mouse_status = MouseStatus.PRESS
    } else {
        if (self.state.mouse_status != MouseStatus.HOVER) {
            window_set_cursor(cr_drag)
        }
        self.state.mouse_status = MouseStatus.HOVER
    }

    if (mouse_check_button_pressed(mb_left) && _over) {
        self.state.click_armed = true
    }

    if (mouse_check_button(mb_left) && _over) {
        self.state.current_subimage = self.state.frame_press
    } else if (_over) {
        self.state.current_subimage = self.state.frame_hover
    } else {
        self.state.current_subimage = self.state.frame_idle
    }

    if (mouse_check_button_released(mb_left)) {
        if (self.state.click_armed && _over) {
            window_set_cursor(cr_drag)
            if (self.state.on_click != undefined) {
                self.state.on_click()
            }
        } else if (!_over) {
            window_set_cursor(cr_arrow)
        }
        self.state.click_armed = false
    }
}

function on_draw_gui() {
    if (!sprite_exists(self.state.sprite)) {
        exit
    }
    var _s = self.state.scale
    draw_sprite_ext(
        self.state.sprite,
        self.state.current_subimage,
        self.state.offset_x + self.state.sprite_offset_x * _s,
        self.state.offset_y + self.state.sprite_offset_y * _s,
        _s, _s,
        0, c_white, 1
    )
}

/// @description Start
on_create()
