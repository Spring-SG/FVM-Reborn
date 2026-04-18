/// 

self.state = {
    left: 0,
    top: 0,
    height: 0,
    width: 0,
    initialized: false,
    auto_draw: false,
    /// @type {function} 
    on_click: undefined,
    scale: 1.8,
    /// @type {Struct.CustomStage} 
    custom_stage: undefined,
    /// @type {Enum.MouseStatus} 
    mouse_status: MouseStatus.NONE,

    /// @type {function ():Bool} 
    should_correspond: function(){return true},
        
    map_sprite_left: 16,
    map_sprite_top: 65,
    map_sprite_scale: 1,
    map_sprite_size: 120,

}

/// @param {Real} _left 
/// @param {Real} _top 
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

/// @param {Bool} _auto_draw 
function set_auto_draw(_auto_draw) {
    self.state.auto_draw = _auto_draw
    return self
}

/// @param {Struct.CustomStage} _custom_stage 
function init(_custom_stage) {
    self.state.custom_stage = _custom_stage
    self.state.initialized = true

    var _map_sprite_original_height = sprite_get_height(_custom_stage.map_sprite)
    self.state.map_sprite_scale = self.state.map_sprite_size / _map_sprite_original_height

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




/// @param {function} _on_click 
function set_on_click(_on_click) {
    self.state.on_click = _on_click
    return self
}

function update_mouse() {
    var _mx = device_mouse_x(0);
    var _my = device_mouse_y(0);
    if (point_in_rectangle(_mx, _my, self.state.left, self.state.top, self.state.left + self.state.width, self.state.top + self.state.height)) {
        if (self.state.mouse_status != MouseStatus.HOVER) {
            window_set_cursor(cr_drag)
        }
        self.state.mouse_status = MouseStatus.HOVER

    } else {
        if (self.state.mouse_status != MouseStatus.NONE) {
            window_set_cursor(cr_arrow)
        }
        self.state.mouse_status = MouseStatus.NONE
    }
}

/// @description Events
function on_create() {
    self.state.width = sprite_get_width(spr_stage_item) * self.state.scale
    self.state.height = sprite_get_height(spr_stage_item) * self.state.scale
}

function on_step() {
    if (!self.state.initialized) exit
    if (is_undefined(self.state.custom_stage)) exit
    if (!self.state.should_correspond()) exit

    update_mouse()
    if (mouse_check_button_pressed(mb_left) && (self.state.mouse_status == MouseStatus.HOVER)) {
        self.state.mouse_status = MouseStatus.PRESS
    }
    if (mouse_check_button_released(mb_left) && (self.state.mouse_status == MouseStatus.HOVER)) {
        self.state.mouse_status = MouseStatus.RELEASE
        window_set_cursor(cr_arrow)
        if (!is_undefined(self.state.on_click) ) {
            self.state.on_click()
        }
    }
}

function on_draw() {
    if (!self.state.initialized) exit
    if (is_undefined(self.state.custom_stage)) exit
    
    draw_sprite_ext(spr_stage_item, 0, self.x, self.y, self.state.scale, self.state.scale, 0, c_white, 1)

    var _prev_scissor = gpu_get_scissor()
    var _sprite_start_x = self.state.left + self.state.map_sprite_left
    var _sprite_start_y = self.state.top + self.state.map_sprite_top
    if (!is_undefined(self.state.custom_stage)) {
        gpu_set_scissor(
            _sprite_start_x, _sprite_start_y, 
            self.state.map_sprite_size, self.state.map_sprite_size)
        draw_sprite_ext(
            self.state.custom_stage.map_sprite, 0, 
            _sprite_start_x, _sprite_start_y, 
            self.state.map_sprite_scale, self.state.map_sprite_scale, 
            0, c_white, 1
        )
        gpu_set_scissor(_prev_scissor)

        draw_set_valign(fa_center)
        draw_text(self.state.left + 30, self.state.top + 34, self.state.custom_stage.name)
        draw_text(self.state.left + 154, self.state.top + 78, self.state.custom_stage.author)
        draw_set_valign(fa_top)
        // TODO: Support multi line render
        draw_text(self.state.left + 156, self.state.top + 115, self.state.custom_stage.description)
    }

}


on_create()