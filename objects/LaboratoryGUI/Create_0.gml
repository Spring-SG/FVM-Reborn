/// 

self.state = {
    bg_scale: 0,
    offset_x: 0,
    offset_y: 0,
    /// @type {Struct.LaboratoryManager} 
    laboratory_manager: undefined,
    /// @type {Array<String>} 
    stage_ids : [],
}

function init_bg_size_and_offset() {
    var _bg_sprite_width = sprite_get_width(spr_laboratory_bg)
    var _width_scale = room_width / _bg_sprite_width
    var _bg_sprite_height = sprite_get_height(spr_laboratory_bg)
    var _height_scale = room_height / _bg_sprite_height

    self.state.bg_scale = min(_width_scale, _height_scale)

    self.state.offset_x = (room_width - _bg_sprite_width * self.state.bg_scale) / 2
    self.state.offset_y = (room_height - _bg_sprite_height * self.state.bg_scale) / 2

}

function create_ui_elements() {
    /// @type {Asset.GMObject.CloseButton} 
    var _close_button = instance_create_layer(0, 0, "Assets", CloseButton)
    _close_button.set_position(room_width - 200, 30)
        .set_on_click(function() {
            global.menu_screen = true
            room_goto(room_menu)
        })
    
    /// @type {Array<Asset.GMObject.StageItem>} 
    var _items = []
    for (var _i = 0; _i < array_length(self.state.stage_ids); _i++) {
        var _stage_id = self.state.stage_ids[_i]
        var _stage = self.state.laboratory_manager.get_stage(_stage_id)
        if (is_undefined(_stage)) {
            return
        }

        /// @type {Asset.GMObject.StageItem} 
        var _item = instance_create_layer(0, 0, "Assets", StageItem)
        _item.init(_stage)
        array_push(_items, _item)
    }

    /// @type {Asset.GMObject.GridList} 
    var _grid_list = instance_create_layer(room_width / 2, room_height / 2, "Assets", GridList)
    _grid_list.set_viewport(159, 175, 1550, 600)
    .set_items(_items)
}

function on_create() {
    if (!variable_global_exists("laboratory_manager") || is_undefined(global.laboratory_manager)) {
        throw("global.laboratory_manager is not defined")
    }

    self.state.laboratory_manager = global.laboratory_manager
    var _stage_ids = self.state.laboratory_manager.get_stage_ids()
    if (array_length(_stage_ids) == 0) {
        var _result = self.state.laboratory_manager.load_all_stages()
        if (_result.is_failed()) {
            throw(_result.message)
        }
        _stage_ids = self.state.laboratory_manager.get_stage_ids()
    }
    self.state.stage_ids = _stage_ids

    global.menu_screen = false
    window_set_cursor(cr_default)

    init_bg_size_and_offset()

    create_ui_elements()
}

function on_draw() {
    draw_sprite_ext(
        spr_laboratory_bg, 0, 
        self.state.offset_x, self.state.offset_y, 
        self.state.bg_scale, self.state.bg_scale, 
        0, c_white, 1)
}

on_create()