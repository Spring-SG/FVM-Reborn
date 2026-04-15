/// 

self.state = {
    scale: 2,
    left: 0,
    top: 0,
    /// @type {Struct.CustomStage} 
    custom_stage: undefined,
    height: 0,
    width: 0,
    /// @type {function} 
    on_close_clicked: undefined,
    /// @type {Asset.GMObject.CloseButton} 
    close_button: undefined
}


/// @param {Struct.CustomStage} _custom_stage 
function init(_custom_stage) {
    self.state.custom_stage = _custom_stage
    return self
}

function set_position(_left, _top) {
    self.state.left = _left
    self.state.top = _top

    if (!is_undefined(self.state.close_button)) {
        self.state.close_button.set_position(_left + self.state.width - 80, _top + 15)
    }

    return self
}

function get_width() {
    return self.state.width
}

function get_height() {
    return self.state.height
}

function on_close() {
    if (!is_undefined(self.state.on_close_clicked)) {
        self.state.on_close_clicked()
        instance_destroy(self.state.close_button)
        self.state.close_button = undefined
        instance_destroy()
    }
}

/// @type {function} _on_close_clicked
function set_on_close_clicked(_on_close_clicked) {
    self.state.on_close_clicked = _on_close_clicked
    return self
}

function create_widgets() {
     /// @type {Asset.GMObject.CloseButton} 
    var _close_button = instance_create_layer(0, 0, "Float", CloseButton)
    _close_button.set_on_click(method(self, on_close))
                 .set_auto_draw(false)
    self.state.close_button = _close_button
}

/// @description Events
function on_create() {
    self.state.height = sprite_get_height(spr_stage_detail) * self.state.scale
    self.state.width = sprite_get_width(spr_stage_detail) * self.state.scale
    create_widgets()
}

function on_step() {

}

function on_draw_gui() {
    draw_sprite_ext(
        spr_stage_detail, 0, 
        self.state.left, self.state.top, 
        self.state.scale, self.state.scale, 
        0, c_white, 1)
    if (!is_undefined(self.state.close_button)) {
        self.state.close_button.on_draw_gui()
    }
}

///
on_create()