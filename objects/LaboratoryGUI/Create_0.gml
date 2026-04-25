/// 
self.state = {
    bg_scale: 0,
    offset_x: 0,
    offset_y: 0,
    /// @type {Struct.LaboratoryManager} 
    laboratory_manager: undefined,
    /// @type {Array<String>} 
    stage_ids : [],
    current_stage_id: "",
    /// @type {Asset.GMObject.StageDetail} 
    stage_detail_widget: undefined,
    /// @type {Asset.GMObject.Button} 
    close_button: undefined,
    /// @type {Asset.GMObject.GridList} 
    grid_list: undefined,
    bottom_button_width: 210,
    bottom_button_height: 170,
    bottom_button_scale: 1,
}

function init_asset_size_and_offset() {
    var _bg_sprite_width = sprite_get_width(spr_laboratory_bg)
    var _width_scale = room_width / _bg_sprite_width
    var _bg_sprite_height = sprite_get_height(spr_laboratory_bg)
    var _height_scale = room_height / _bg_sprite_height

    self.state.bg_scale = min(_width_scale, _height_scale)

    self.state.offset_x = (room_width - _bg_sprite_width * self.state.bg_scale) / 2
    self.state.offset_y = (room_height - _bg_sprite_height * self.state.bg_scale) / 2

    var _bottom_button_width = sprite_get_width(spr_doctor_shop)
    self.state.bottom_button_scale = self.state.bottom_button_width / _bottom_button_width

}

function refresh_custom_stages() {
    var _stage_ids = self.state.laboratory_manager.get_stage_ids()
    self.state.laboratory_manager.reset()
    var _result = self.state.laboratory_manager.load_all_stages()
    if (_result.is_failed()) {
        show_message_async("加载某些关卡出现问题，日志已经复制到剪贴板中")
        clipboard_set_text(_result.message)
    }
    _stage_ids = self.state.laboratory_manager.get_stage_ids()
    self.state.stage_ids = _stage_ids

    /// @description Stage List
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
             .set_on_click(method({stage_id: _stage_id, gui_state: self.state}, function() {
                 gui_state.current_stage_id = stage_id
             }))
             .set_should_correspond(method({gui_state: self.state}, function() {
                return gui_state.current_stage_id == ""
             }))
        _item.visible = false
        array_push(_items, _item)
    }
    self.state.grid_list.set_items(_items)
}

function create_widgets() {
    /// @description Close Button
    /// @type {Asset.GMObject.Button} 
    var _close_button = instance_create_layer(0, 0, "Assets", Button)
    _close_button.set_position(room_width - 170, 60)
        .set_sprite(spr_closemenu_btn)
        .set_scale(1.9)
        .set_frames(0, 1, 2)
        .set_on_click(function() {
            global.menu_screen = true
            global.gui_stack.pop()
            window_set_cursor(cr_arrow)
        })
        .set_should_correspond(method({gui_state: self.state}, function() {
            return gui_state.current_stage_id == ""
        }))
    self.state.close_button = _close_button
        
    /// @type {Asset.GMObject.GridList} 
    var _grid_list = instance_create_layer(room_width / 2, room_height / 2, "Assets", GridList)
    _grid_list.set_viewport(159, 175, 1550, 600)
              .set_items([])
    self.state.grid_list = _grid_list

    /// @type {Asset.GMObject.Button} 
    var _reset_button = instance_create_layer(0, 0, "Assets", Button)
    _reset_button.set_sprite(spr_refresh_button)
        .set_position(159, 110)
        .set_scale(1.2)
        .set_on_click(method({func: refresh_custom_stages}, function() {
            func()
        }))
        .set_should_correspond(method({gui_state: self.state}, function() {
            return gui_state.current_stage_id == ""
        }))

    /// @description Bottom Button
    /// @type {Asset.GMObject.Button} 
    var _my_stage_button = instance_create_layer(0, 0, "Assets", Button)
    _my_stage_button.set_sprite(spr_my_stages)
        .set_scale(self.state.bottom_button_scale)
        .set_position(1180, 843)
        .set_should_correspond(method({gui_state: self.state}, function() {
            return gui_state.current_stage_id == ""
        }))
        .set_on_click(method({}, function() {
            var _result = global.laboratory_manager.file_util.create_folder_if_not_exist(kCustomStageFolder)
            if (_result.is_failed()) {
                show_message_async(_result.message)
            }
            var _target = global.laboratory_manager.file_util.transfer_path_to_windows(working_directory + "/" + kCustomStageFolder)
            native_open_folder(_target)
        }))
}

function on_create() {
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
    init_asset_size_and_offset()
    var _text = clipboard_get_text()
    show_debug_message("Clipboard: " + _text)

    if (!variable_global_exists("laboratory_manager") || is_undefined(global.laboratory_manager)) {
        throw("global.laboratory_manager is not defined")
    }
    
    self.state.laboratory_manager = global.laboratory_manager

    global.menu_screen = false
    window_set_cursor(cr_arrow)
    
    create_widgets()
    refresh_custom_stages()
}

function on_step() {
    if (!is_undefined(self.state.stage_detail_widget)) exit
    if (self.state.current_stage_id == "") exit

    /// @type {Asset.GMObject.StageDetail} 
    var _detail_widget = instance_create_layer(0, 0, "Float", StageDetail)
    if (_detail_widget == -1) {
        throw("Failed to create stage detail widget")
    }
    _detail_widget.init(self.state.laboratory_manager.get_stage(self.state.current_stage_id))
                  .set_position((room_width - _detail_widget.get_width()) / 2, (room_height - _detail_widget.get_height()) / 2)
                  .set_on_close_clicked(method({gui_state: self.state}, function() {
                      gui_state.current_stage_id = ""
                      gui_state.stage_detail_widget = undefined
                  }))
    self.state.stage_detail_widget = _detail_widget
}

function on_draw() {
    draw_sprite_ext(
        spr_laboratory_bg, 0, 
        self.state.offset_x, self.state.offset_y, 
        self.state.bg_scale, self.state.bg_scale, 
        0, c_white, 1)
    draw_sprite_ext(
        spr_doctor_shop, 0,
        882, 852,
        self.state.bottom_button_scale, self.state.bottom_button_scale,
        0, c_white, 1
    )
    // draw_sprite_ext(
    //     spr_my_stages, 0,
    //     1180, 843,
    //     self.state.bottom_button_scale, self.state.bottom_button_scale,
    //     0, c_white, 1
    // )
    draw_sprite_ext(
        spr_search_team, 0,
        1480, 852,
        self.state.bottom_button_scale, self.state.bottom_button_scale,
        0, c_white, 1
    )
}

on_create()