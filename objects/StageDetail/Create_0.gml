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
        self.state.close_button.set_position(_left + self.state.width - 50, _top + 44)
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
    if (global.network.mode == "server") {
        var _json_struct = {
            target_level_id: global.level_id,
            level_index: 0,
            map_id: global.map_id,
            level_data: global.level_data,
            level_file: global.level_file
        }
        // 自定义资源：发送文件名和指纹，客户端指纹一致则跳过传输
        // 只发原始相对路径，不泄露房主本地完整路径
        var _raw_json = _parse_result.data
        var _resource_fingerprints = {}
        var _json_dir = self.state.custom_stage.json_path
        global._file_cache_json_path = _json_dir

        var _sprite_rel = ""
        var _sprite_path_raw = variable_struct_get(_raw_json, "map_sprite")
        if (!is_undefined(_sprite_path_raw) && string_length(string(_sprite_path_raw)) > 0) {
            if (laboratory_path_is_relative(string(_sprite_path_raw))) {
                _sprite_rel = string(_sprite_path_raw)
                variable_struct_set(_json_struct, "map_sprite_name", _sprite_rel)
                _resource_fingerprints[$ "map_sprite"] = file_cache_compute_fingerprint(
                    laboratory_resolve_datafile_path(_sprite_rel, _json_dir))
            }
        }

        var _check_custom_music = function(_raw_json,_field) {
            var _path = variable_struct_get(_raw_json, _field)
            return !is_undefined(_path) && laboratory_path_is_relative(string(_path))
        }
        var _custom_music_names = {}
        if (_check_custom_music(_raw_json,"pre_music") || _check_custom_music(_raw_json,"elite_music") || _check_custom_music(_raw_json,"boss_music")) {
            var _ld = _json_struct[$ "level_data"]
            _ld[$ "pre_music"]   = mus_delicious_island_daytime_pre
            _ld[$ "elite_music"] = mus_delicious_island_daytime_elite
            _ld[$ "boss_music"]  = mus_delicious_island_daytime_boss
            if (_check_custom_music(_raw_json,"pre_music")) {
                var _rel = string(variable_struct_get(_raw_json, "pre_music"))
                _custom_music_names[$ "pre_music"] = _rel
                _resource_fingerprints[$ "pre_music"] = file_cache_compute_fingerprint(
                    laboratory_resolve_datafile_path(_rel, _json_dir))
            }
            if (_check_custom_music(_raw_json,"elite_music")) {
                var _rel = string(variable_struct_get(_raw_json, "elite_music"))
                _custom_music_names[$ "elite_music"] = _rel
                _resource_fingerprints[$ "elite_music"] = file_cache_compute_fingerprint(
                    laboratory_resolve_datafile_path(_rel, _json_dir))
            }
            if (_check_custom_music(_raw_json,"boss_music")) {
                var _rel = string(variable_struct_get(_raw_json, "boss_music"))
                _custom_music_names[$ "boss_music"] = _rel
                _resource_fingerprints[$ "boss_music"] = file_cache_compute_fingerprint(
                    laboratory_resolve_datafile_path(_rel, _json_dir))
            }
            variable_struct_set(_json_struct, "custom_music_names", _custom_music_names)
        }
        variable_struct_set(_json_struct, "resource_fingerprints", _resource_fingerprints)

        // 存全局，供 obj_shell 新客户端重发同步
        global._sync_map_sprite_name = _sprite_rel;
        global._sync_custom_music_names = _custom_music_names;
        global._sync_resource_fingerprints = _resource_fingerprints;

        var _json = json_stringify(_json_struct)
		
		
        var _list = global.network.connected_clients;
        for (var _i = 0; _i < array_length(_list); _i++) {
            send_message(_list[_i], MSG_ENTER_ROOM_READY, _json);
        }
    }
    global.gui_stack.to(room_ready)
    window_set_cursor(cr_arrow)
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

function on_draw() {
    draw_sprite_ext(
        spr_stage_detail, 0, 
        self.state.left, self.state.top, 
        self.state.scale, self.state.scale, 
        0, c_white, 1)

    if( !is_undefined(self.state.close_button)) {
        self.state.close_button.on_draw()
    }
    if( !is_undefined(self.state.start_button)) {
        self.state.start_button.on_draw()
    }
    if (!is_undefined(self.state.custom_stage)) {
        scribble(self.state.custom_stage.name, "stage_detail_name")
            .align(fa_center, fa_center)
            .scale(1.2)
            .starting_format("font_hei_outline_4dir_black")
            .draw(self.state.left + (self.state.width / 2),  self.state.top + 114)

        scribble(self.state.custom_stage.id)
            .draw(self.state.left + 160, self.state.top + 170)

        scribble(self.state.custom_stage.author)
            .draw(self.state.left + 130, self.state.top + 228)
        scribble(self.state.custom_stage.description, "stage_detail_desc")
            .wrap(650, 360)
            .line_spacing("90%")
            .scale(1.0)
            .draw(self.state.left + 50, self.state.top + 300)

        draw_sprite_ext(spr_level_progress_icon, 0, 
            self.state.left + 60, self.state.top + self.state.height - 90, 
            1.5, 1.5, 
            0, c_white, 1)
        scribble("Lv." +  string(self.state.custom_stage.mouse_level))
            .draw(self.state.left + 90, self.state.top+self.state.height-108)
        
        draw_sprite_ext(spr_flame_small, 0, 
            self.state.left + 200, self.state.top + self.state.height - 90, 
            0.95, 0.95, 
            0, c_white, 1)
        scribble(string(self.state.custom_stage.initial_energy))
            .draw(self.state.left + 230, self.state.top+self.state.height-106)
        
        draw_sprite_ext(spr_level_progress_flag, 0, 
            self.state.left + 340, self.state.top + self.state.height - 80, 
            1.2, 1.2, 
            0, c_white, 1)
        scribble(string(self.state.custom_stage.total_waves))
            .draw(self.state.left + 370, self.state.top+self.state.height-106)
        
        draw_sprite_ext(spr_clock, 0, 
            self.state.left + 38, self.state.top + self.state.height - 70, 
            0.5, 0.5, 
            0, c_white, 1)
        scribble(string(self.state.custom_stage.time_limit) + "\"")
            .draw(self.state.left + 90, self.state.top+self.state.height-65)

        draw_sprite_ext(spr_first_wave_time, 0, 
            self.state.left + 178, self.state.top + self.state.height - 70, 
            0.5, 0.5, 
            0, c_white, 1)
        scribble(string(self.state.custom_stage.prepare_time) + "\"")
            .draw(self.state.left + 230, self.state.top+self.state.height-65)
      
    }
}

///
on_create()

