/// 
function LaboratoryManager() constructor {

    self.dynamic_audios = {}
    self.stages = {}
    /// @type {Array<String>} 
    self.stage_ids = []
    /// @type {Struct.FileUtil} 
    self.file_util = undefined

    /// @returns {Struct.Result} 
    static init = function() {
        self.file_util = new FileUtil()
        return new Result().success()
    }

    /// @type {Array<String>} 
    static get_stage_ids = function() {
        return self.stage_ids
    }

    /// @param {String} _stage_id 
    /// @returns {Struct.CustomStage|Undefined} 
    static get_stage = function(_stage_id) {
        return variable_struct_get(self.stages, _stage_id)
    }

    /// @param {String} _stage_id
    /// @param {Struct.CustomStage} _stage 
    static _add_stage = function(_stage_id, _stage) {
        variable_struct_set(self.stages, _stage_id, _stage)
    }

    /// @param {String} _json_path 
    /// @returns {Struct.Result} 
    static _load_stage = function(_json_path) {
        var _result = self.file_util.load_json_from_path(_json_path)
        if (_result.is_failed()) {
            return _result
        }

        var _json = _result.data
        var _stage = create_custom_stage(_json, _json_path)
        var _verify_result = verify_stage(_stage)
        if (_verify_result.is_failed()) {
            return _verify_result
        }
        self._add_stage(_stage.id, _stage)
        array_push(self.stage_ids, _stage.id)
        return new Result().success()
    }

    /// @param {String} _audio_key
    /// @returns {Struct.GMSound|Undefined}
    static _get_dynamic_audio = function(_audio_key) {
        return variable_struct_get(self.dynamic_audios, _audio_key)
    }

    /// @param {String} _audio_key
    /// @param {Struct.GMSound} _dynamic_audio
    static _add_dynamic_audio = function(_audio_key, _dynamic_audio) {
        variable_struct_set(self.dynamic_audios, _audio_key, _dynamic_audio)
    }

    
    /// @param {String} _path
    /// @returns {Struct.GMSound|Undefined}
    static load_dynamic_audio = function(_path) {
        var _sound = _get_dynamic_audio(_path)
        if (!is_undefined(_sound)) {
            return _sound
        }
        var _result = self.file_util.load_sound_from_path(_path)
        if (_result.is_failed()) {
            return undefined
        }
        _sound = _result.data
        _add_dynamic_audio(_path, _sound)
        return _sound
    }


    static register_all_stages = function() {
        var _level_datas = []
        for (var i = 0; i < array_length(self.stage_ids); i++) {
            var _stage_id = self.stage_ids[i]
            var _stage = self.get_stage(_stage_id)
            var _level_data = level_entry_from_stage_metadata(_stage)
            array_push(_level_datas, _level_data)
        }
        var _map_data = {
            map_name: "laboratory",
            map_sprite: -1,
            level_datas: _level_datas
        }
        if (ds_map_exists(global.maps_map, "laboratory")) {
            ds_map_replace(global.maps_map, "laboratory", _map_data)
        } else {
            ds_map_add(global.maps_map, "laboratory", _map_data)
        }
    }

    /// @returns {Struct.Result} 
    static load_all_stages = function() {
        var error_message = ""
        var _json_path_list = self.file_util.find_files_with_extension_recursively(kCustomStageFolder, ".json")
        for (var i = 0; i < array_length(_json_path_list); i++) {
            var _json_path = _json_path_list[i]
            var _result = self._load_stage(_json_path)
            if (_result.is_failed()) {
                error_message += _result.get_error_stack()
            }
        }
        if (error_message != "") {
            return new Result().fail(ErrorCode.INVALID_METADATA, "error occurred while loading stages:\n" + error_message)
        }
        return new Result().success()
    }

    static remove_all_audios = function() {
        for (var i = 0; i < array_length(self.dynamic_audios); i++) {
            audio_destroy_stream(self.dynamic_audios[i])
        }
    }

    static reset = function() {
        remove_all_audios()
        self.stages = {}
        self.stage_ids = []
    }

    static dispose = function() {
        remove_all_audios()
        self.stages = {}
        self.file_util = undefined
    }
}