/// 

self.state = {
    scale: 1.9,
    left: 0,
    top: 0,
    /// @type {Struct.CustomStage} 
    custom_stage: undefined,
    height: 0,
    width: 0,
    /// @type {function} 
    on_close_clicked: undefined,
    /// @type {Asset.GMObject.Button} 
    close_button: undefined,
    /// @type {Asset.GMObject.Button} 
    start_button: undefined,

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
        self.state.close_button.set_position(_left + self.state.width - 50, _top + 35)
    }
    if (!is_undefined(self.state.start_button)) {
        self.state.start_button.set_position(self.state.left + self.state.width - 240, self.state.top + self.state.height - 110)

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

function on_create_room() {
    if (is_undefined(self.state.custom_stage)) {
        return
    }
    var _parse_result = global.laboratory_manager.file_util.load_json_from_path(self.state.custom_stage.json_path)
    if (_parse_result.is_failed()) {
        throw _parse_result.get_error_stack()
    }
    var _level_data = level_entry_from_stage_metadata(self.state.custom_stage)
    global.level_data = _level_data
    global.level_id = self.state.custom_stage.id
    global.level_file = _parse_result.data
    global.gui_stack.to(room_ready)
}

/// @type {function} _on_close_clicked
function set_on_close_clicked(_on_close_clicked) {
    self.state.on_close_clicked = _on_close_clicked
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

    /// @type {Asset.GMObject.Button} 
    var start_button = instance_create_layer(0, 0, "Float", Button)
    start_button.set_auto_draw(false)
        .set_sprite(spr_create_room)
        .set_scale(2)
        .set_on_click(method(self, on_create_room))
    self.state.start_button = start_button
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

    if( !is_undefined(self.state.close_button)) {
        self.state.close_button.on_draw_gui()
    }
    if( !is_undefined(self.state.start_button)) {
        self.state.start_button.on_draw_gui()
    }
    if (!is_undefined(self.state.custom_stage)) {
        draw_text(self.state.left + 160, self.state.top + 175, self.state.custom_stage.id)
        draw_text(self.state.left + 500, self.state.top + 175, self.state.custom_stage.name)
        draw_text(self.state.left + 130, self.state.top + 213, self.state.custom_stage.author)
        // TODO: Support multi line render
        draw_text(self.state.left + 55, self.state.top + 340, self.state.custom_stage.description)
      
    }
}

///
on_create()

