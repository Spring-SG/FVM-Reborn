/// 

#macro kCustomStageFolder "laboratory"

enum MouseStatus {
    NONE = 0,
    HOVER = 1,
    PRESS = 2,
    RELEASE = 3,
}

enum ErrorCode {
    NO_SUCH_FILE = 0x1001,
    NO_SUCH_RESOURCE = 0x1002,
    LOAD_RESOURCE_FAILED = 0x1003,
    JSON_PARSE_FAILED = 0x1004,
    CREATE_FILE_FAILED = 0x1005,
    
    // mod_loader
    INVALID_METADATA = 0x2001,
    LOAD_LUA_FAILED = 0x2002,
    CALL_LUA_FAILED = 0x2003,
    GET_LUA_VARIABLE_FAILED = 0x2004,
    SET_LUA_VARIABLE_FAILED = 0x2005,
    GET_LUA_FUNCTION_FAILED = 0x2006,
    SET_LUA_FUNCTION_FAILED = 0x2007,
    GET_LUA_PROPERTY_FAILED = 0x2008,
    INVALID_TYPE = 0x2009,

    // gui_stack
    GUI_STACK_EMPTY = 0x3001,
    GUI_INVALID_ROOM = 0x3002,
}

function ScissorArea() constructor {
    self.x = 0
    self.y = 0
    self.w = 0
    self.h = 0
}

function Result() constructor {
    self.code = 0
    self.message = ""
    /// @type {Any|Undefined} 
    self.data = undefined
    /// @type {Array<Enum.ErrorCode>} 
    self.code_stack = []
    /// @type {Array<String>} 
    self.message_stack = []

    /// @returns {Bool} 
    static is_succeed = function() {
        return self.code == 0
    }

    /// @returns {Bool} 
    static is_failed = function() {
        return self.code != 0
    }

    /// @template {T}  
    /// @param {T|Undefined} _data 
    /// @returns {Struct.Result} 
    static success = function(_data = undefined) {
        var _result = new Result()
        _result.code = 0
        _result.data = _data
        return _result
    }

    /// @param {Enum.ErrorCode} _code 
    /// @param {String} _message 
    /// @returns {Struct.Result} 
    static fail = function(_code, _message) {
        var _result = new Result()
        _result.code = _code
        _result.message = _message
        return _result
    }

    /// @param {Enum.ErrorCode} _code 
    /// @param {String} _message 
    /// @returns {Struct.Result} 
    static wrap = function(_code, _message) {
        array_push(self.code_stack, _code)
        array_push(self.message_stack, _message)
        return self
    }

    /// @returns {String} 
    static get_error_stack = function() {
        var _stack = ""
        for (var i = array_length(self.code_stack) - 1; i >= 0; i--) {
            _stack += "Code: " + string(self.code_stack[i]) + ", Message: " + self.message_stack[i] + "\n"
        }
        _stack += "Final Code: " + string(self.code) + ", Final Message: " + self.message + "\n"
        return _stack
    }
}

function CustomStage() constructor {
    self.name = ""
    self.author = ""
    self.version = ""
    self.id = ""
    self.description = ""
    self.total_waves = 0
    self.prepare_time = 0
    self.star_limit = 0
    self.time_limit = 0
    self.allow_pet = true
    self.allow_equipment = true
    self.initial_energy = 0
    self.mouse_level = 0 
    /// @type {Asset.GMSprite} 
    self.map_sprite = -1
    /// @type {Asset.GMSound} 
    self.pre_music = -1
    /// @type {Asset.GMSound} 
    self.elite_music = -1
    /// @type {Asset.GMSound} 
    self.boss_music = -1

    self.json_path = ""


}

/// @param {String} _path
/// @param {String} _path_prefix
/// @returns {Asset.GMSound}
function get_audio_or_create(_path, _path_prefix) {
    if (string_starts_with(_path, "./") || string_starts_with(_path, "../") || string_starts_with(_path, ".\\") || string_starts_with(_path, "..\\")) {
		if (!string_ends_with(_path_prefix, "/") && !string_ends_with(_path_prefix, "\\")) {
			_path_prefix = _path_prefix + "/"
		}
        _path_prefix += "../"
		return global.laboratory_manager.load_dynamic_audio(_path_prefix + _path)
	}

    return asset_get_index(_path)
}


/// @param {Struct} _json 
/// @param {String} _json_path
/// @returns {Struct.CustomStage} 
function create_custom_stage(_json, _json_path) {
    var _stage = new CustomStage()
    _stage.name = variable_struct_get(_json,"display_name")
    _stage.author = variable_struct_get(_json,"author")
    _stage.version = variable_struct_get(_json,"version")
    _stage.id = _json_path
    _stage.description = variable_struct_get(_json,"desc")
    _stage.total_waves = variable_struct_get(_json,"total_waves")
    _stage.prepare_time = variable_struct_get(_json,"first_wave_delay")
    _stage.star_limit = 16
    _stage.time_limit = variable_struct_get(_json,"time_limit")   
    _stage.allow_pet = true
    _stage.allow_equipment = true
    _stage.initial_energy = variable_struct_get(_json,"starting_flame")
    _stage.mouse_level = variable_struct_get(_json,"hp_modify")
    
    _stage.json_path = _json_path

    var _sprite = variable_struct_get(_json,"map_sprite")
    _stage.map_sprite = asset_get_index(_sprite) 

    /// @type {String} 
    var _pre_music_path = variable_struct_get(_json,"pre_music")
    _stage.pre_music = get_audio_or_create(_pre_music_path, _json_path)

    var _elite_music_path = variable_struct_get(_json,"elite_music")
    _stage.elite_music = get_audio_or_create(_elite_music_path, _json_path)

    var _boss_music_path = variable_struct_get(_json,"boss_music")
    _stage.boss_music = get_audio_or_create(_boss_music_path, _json_path)

    return _stage
}


/// @param {Struct.CustomStage} _meta 
/// @returns {Struct}  One entry compatible with global.maps_map levels_data (see maps_init)
function level_entry_from_stage_metadata(_meta) {
    var lf = string_replace_all(string(_meta.json_path), "\\", "/")
    var hf = lf
    var spr_ix = _meta.map_sprite
    if (spr_ix == -1) {
        spr_ix = spr_cookie_island
    }
    var pre_ix = _meta.pre_music
    var elite_ix = _meta.elite_music
    var boss_ix = _meta.boss_music
    var bx = -1
    var by = -1
    return {
        id: _meta.id,
        name: _meta.name,
        button_spr: spr_levelselect_button,
        button_index: -1,
        button_x: bx,
        button_y: by,
        level_file: lf,
        hard_level_file: hf,
        level_sprite: spr_ix,
        pre_music: pre_ix,
        elite_music: elite_ix,
        boss_music: boss_ix,
        player_level_require: 1,
        pre_level_require: []
    }
}

/// @param {Struct.CustomStage} _stage 
/// @returns {Struct.Result}
function verify_stage(_stage) {
    if (_stage.map_sprite == -1) {
        return new Result().fail(ErrorCode.INVALID_METADATA, "stage " + _stage.json_path + " has no valid map sprite")
    }
    if (_stage.pre_music == -1) {
        return new Result().fail(ErrorCode.INVALID_METADATA, "stage " + _stage.json_path + " has no valid pre music")
    }
    if (_stage.elite_music == -1) {
        return new Result().fail(ErrorCode.INVALID_METADATA, "stage " + _stage.json_path + " has no valid elite music")
    }
    if (_stage.boss_music == -1) {
        return new Result().fail(ErrorCode.INVALID_METADATA, "stage " + _stage.json_path + " has no valid boss music")
    }
    return new Result().success()
}