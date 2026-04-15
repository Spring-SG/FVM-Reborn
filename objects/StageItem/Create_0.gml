/// 

self.state = {
    left: 0,
    top: 0,
    initialized: false,
    auto_draw: false,
    scale: 1.8,
    /// @type {Struct.CustomStage} 
    custom_stage: undefined,
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
    return sprite_get_height(spr_stage_item) * self.state.scale
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
    return self
}


function on_create() {
}

function on_step() {
    if (!self.state.initialized) exit
    if (is_undefined(self.state.custom_stage)) exit
}

function on_draw_gui() {
    if (!self.state.initialized) exit
    if (is_undefined(self.state.custom_stage)) exit
    
    draw_sprite_ext(spr_stage_item, 0, self.x, self.y, self.state.scale, self.state.scale, 0, c_white, 1)

}