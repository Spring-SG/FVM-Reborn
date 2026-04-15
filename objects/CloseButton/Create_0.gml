/// 
self.state = {
    offset_x: 0,
    offset_y: 0,
    scale: 1.9,
    /// @type {function} 
    on_click: undefined,
    
    corresponding_area_l: 0,
    corresponding_area_r: 0,
    corresponding_area_t: 0,
    corresponding_area_b: 0,

    sprite_offset_x: 17,
    sprite_offset_y: 12,
    current_frame: 0,
    /// @type {Enum.MouseStatus} 
    mouse_status: MouseStatus.NONE,
    auto_draw: true,
}


/// @param {Real} _left 
/// @param {Real} _top 
/// @returns {Asset.GMObject.CloseButton} 
function set_position(_left, _top) {
    self.state.offset_x = _left
    self.state.offset_y = _top
    self.state.corresponding_area_l = _left
    self.state.corresponding_area_r = _left + sprite_get_width(spr_closemenu_btn) * self.state.scale
    self.state.corresponding_area_t = _top
    self.state.corresponding_area_b = _top + sprite_get_height(spr_closemenu_btn) * self.state.scale

    return self
}

/// @returns {Asset.GMObject.CloseButton} 
function set_auto_draw(_auto_draw) {
    self.state.auto_draw = _auto_draw
    return self
}

/// @param {function} _on_click 
/// @returns {Asset.GMObject.CloseButton} 
function set_on_click(_on_click) {
    self.state.on_click = _on_click
    return self
}


function update_mouse() {
    var _mx = device_mouse_x_to_gui(0);
    var _my = device_mouse_y_to_gui(0);
    if (point_in_rectangle(_mx, _my, self.state.corresponding_area_l, self.state.corresponding_area_t, self.state.corresponding_area_r, self.state.corresponding_area_b)) {
        if (self.state.mouse_status != MouseStatus.HOVER) {
            window_set_cursor(cr_drag)
        }
        self.state.mouse_status = MouseStatus.HOVER
        self.state.current_frame = 1
    } else {
        if (self.state.mouse_status != MouseStatus.NONE) {
            window_set_cursor(cr_arrow)
        }
        self.state.mouse_status = MouseStatus.NONE
        self.state.current_frame = 0
    }
}


/// @description events


function on_create() {

}

function on_step() {
    update_mouse()
    if (mouse_check_button_pressed(mb_left) && (self.state.mouse_status == MouseStatus.HOVER)) {
        self.state.mouse_status = MouseStatus.PRESS
        self.state.current_frame = 2
    }
    if (mouse_check_button_released(mb_left) && (self.state.mouse_status == MouseStatus.HOVER)) {
        self.state.mouse_status = MouseStatus.RELEASE
        window_set_cursor(cr_arrow)
        self.state.current_frame = 1

        if (self.state.on_click != undefined) {
            
            self.state.on_click()
        }
    }
    // HACK: for debug
    if (mouse_check_button_released(mb_left)) {
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        show_debug_message("Released at position: " + string(_mx) + ", " + string(_my))
    }
}

function on_draw_gui() {
    draw_sprite_ext(spr_closemenu_btn, self.state.current_frame,
        self.state.offset_x + self.state.sprite_offset_x * self.state.scale, self.state.offset_y + self.state.sprite_offset_y * self.state.scale,
        self.state.scale, self.state.scale, 0, c_white, 1)
}