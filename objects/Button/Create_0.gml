/// 
self.state = {
    /// @type {Asset.GMSprite} 
    sprite: spr_laboratory_icon,
    /// offset 为精灵原点（origin）在房间坐标中的位置，与 draw_sprite_ext 一致；热区按整图外接矩形并抵消 sprite 锚点。
    offset_x: 0,
    offset_y: 0,
    scale: 1,
    sprite_offset_x: 0,
    sprite_offset_y: 0,

    height: 0,
    width: 0,

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
    prev_mouse_status: MouseStatus.NONE,
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

function get_height() {
    return self.state.height
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
    self.state.height = sprite_get_height(self.state.sprite) * _scale
    self.state.width = sprite_get_width(self.state.sprite) * _scale
    refresh_hitbox()
    return self
}

/// @param {Real} _left 精灵原点 X（与 draw_sprite_ext 一致，非贴图左上角）
/// @param {Real} _top 精灵原点 Y
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
    self.state.height = sprite_get_height(self.state.sprite)
    self.state.width = sprite_get_width(self.state.sprite)
}

function on_step() {
    var _s = self.state
    
    if (!_s.should_correspond()) exit
    if (!sprite_exists(_s.sprite)) exit

    var _mx = device_mouse_x(0)
    var _my = device_mouse_y(0)
    var _over = point_in_rectangle(_mx, _my, _s.corresponding_area_l, _s.corresponding_area_t, _s.corresponding_area_r, _s.corresponding_area_b)
    var _old_status = _s.mouse_status
    var _mouse_press = mouse_check_button(mb_left)
    var _mouse_down = mouse_check_button_pressed(mb_left)
    var _mouse_up = mouse_check_button_released(mb_left)

    if (!_over) {
        _s.mouse_status = MouseStatus.NONE
        _s.current_subimage = _s.frame_idle
    } else {
        if (_mouse_press) {
            _s.mouse_status = MouseStatus.PRESS
            _s.current_subimage = _s.frame_press
            if (_mouse_down) _s.click_armed = true
        } else {
            _s.mouse_status = MouseStatus.HOVER
            _s.current_subimage = _s.frame_hover
            
            if (_mouse_up && _s.click_armed) {
                if (!is_undefined(_s.on_click)) _s.on_click()
            }
        }
    }

    if (_mouse_up) _s.click_armed = false

    if (_s.mouse_status != _old_status) {
        if (_s.mouse_status == MouseStatus.NONE) {
            window_set_cursor(cr_arrow)
        } else {
            window_set_cursor(cr_drag)
        }
    }
}

function on_draw() {
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
