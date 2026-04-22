/// 
function FileUtil() constructor {
    /// @param {String} _path 
    /// @returns {Array<String>} 
    static find_sub_folders = function(_path) {
        var _sub_folders = []
        if (!directory_exists(_path)) {
            return _sub_folders
        }
        show_debug_message("Find sub folders at: " + _path);
        var _folder_name = file_find_first(_path + "*", fa_directory)
        while (_folder_name != "") {
            if (directory_exists(_path + _folder_name)) {
                if (_folder_name == "." || _folder_name == "..") {
                    continue
                }
                array_push(_sub_folders, _path + _folder_name)
            }
            _folder_name = file_find_next()
        }
        file_find_close()
        return _sub_folders
    }

    /// @param {String} _path 
    /// @returns {String}
    static transfer_path_to_windows = function(_path) {
        return string_replace(_path, "/", "\\")
    }

    /// @description return full path of files with specific extension in the folder
    /// @param {String} _path 
    /// @param {String} _extension 
    /// @returns {Array<String>} full path of files
    static find_files_with_extension_recursively = function(_path, _extension) {
        var _files = [];
        
        if (string_char_at(_path, string_length(_path)) != "/") {
            _path += "/";
        }

        if (!directory_exists(_path)) return _files;

        var _temp_list = [];
        var _item = file_find_first(_path + "*.*", fa_directory | fa_archive | fa_readonly);
        
        while (_item != "") {
            if (_item != "." && _item != "..") {
                array_push(_temp_list, _item);
            }
            _item = file_find_next();
        }
        file_find_close(); 

        var _count = array_length(_temp_list);
        for (var i = 0; i < _count; i++) {
            var _name = _temp_list[i];
            var _full_path = _path + _name;

            if (directory_exists(_full_path)) {
                var _sub_results = self.find_files_with_extension_recursively(_full_path, _extension);
                _files = array_concat(_files, _sub_results);
            } else {
                if (string_ends_with(_name, _extension)) {
                    array_push(_files, _full_path);
                }
            }
        }

        return _files;
    }

    /// @param {String} _path 
    /// @param {String} _data 
    static append_data_to_file = function(_path, _data) {
        try {
            var _file = file_text_open_append(_path);
            if (_file == -1) {
                return new Result().fail(ErrorCode.CREATE_FILE_FAILED, "Failed to create file: " + _path);
            }
            file_text_write_string(_file, _data + "\n");
            file_text_close(_file);
        } catch (e) {
            return new Result().fail(ErrorCode.CREATE_FILE_FAILED, "Failed to create file: " + _path + "\n" + string(e));
        }
        return new Result().success();
    }

    /// @returns {Struct.Result} 
    static create_file_if_not_exist = function(_path) {
        try {
            if (file_exists(_path)) {
                return new Result().success()
            }
            var _dir = filename_dir(_path);
            if (_dir != "" && !directory_exists(_dir)) {
                directory_create(_dir);
            }

            var _file = file_text_open_write(_path);
            
            if (_file == -1) {
                return new Result().fail(ErrorCode.CREATE_FILE_FAILED, "Failed to create file: " + _path);
            }
            file_text_close(_file);
            if (!file_exists(_path)) {
                return new Result().fail(ErrorCode.CREATE_FILE_FAILED, "Failed to create file: " + _path);
            }
        } catch (e) {
            return new Result().fail(ErrorCode.CREATE_FILE_FAILED, "Failed to create file: " + _path + "\n" + string(e));
        }
        return new Result().success();
    }

    /// @param {String} _path
    /// @returns {Struct.Result} 
    static create_folder_if_not_exist = function(_path) {
        if (!directory_exists(_path)) {
            var _result = directory_create(_path);
            if (!_result) {
                return new Result().fail(ErrorCode.NO_SUCH_FILE, "Failed to create folder: " + _path);
            }
        }
        return new Result().success()
    }

    /// @param {String} _path 
    /// @returns {Struct.Result<Struct>} 
    static load_json_from_path = function(_path) {
        if (!file_exists(_path)) {
            return new Result().fail(ErrorCode.NO_SUCH_FILE, "File not found: " + _path)
        }
        var _buffer = buffer_load(_path);
        if (!buffer_exists(_buffer)) {
            return new Result().fail(ErrorCode.NO_SUCH_FILE, "Could not load file into buffer: " + _path)
        }
        var _raw_json = buffer_read(_buffer, buffer_string);
        buffer_delete(_buffer);
        try {
            var _json = json_parse(_raw_json);
            if (!is_struct(_json) && !is_array(_json)) {
                return new Result().fail(ErrorCode.JSON_PARSE_FAILED, "Failed to parse json, root must be struct or array: " + _path);
            }

            return new Result().success(_json);
        } catch (e) {
            return new Result().fail(ErrorCode.JSON_PARSE_FAILED, "Failed to parse json: " + _path + "\n" + string(e));
        }
    }

    /// @description Path passed to buffer_load：内置关卡为 level_data/…；模组为 mods/…（与 level_data 同级）；或绝对路径。
    /// @param {String} _level_file  maps_init level_file (often relative to level_data/)
    /// @param {String} [_hard_file] 
    /// @param {Bool} [_use_hard] 
    /// @returns {String} 
    static resolve_level_data_buffer_path = function(_level_file, _hard_file = undefined, _use_hard = false) {
        var f = (_use_hard && _hard_file != undefined && string(_hard_file) != "") ? string(_hard_file) : string(_level_file)
        if (f == "") {
            return f
        }
        f = string_replace_all(f, "\\", "/")
        if (string_length(f) >= 2 && string_char_at(f, 2) == ":") {
            return f
        }
        if (string_length(f) >= 1 && string_char_at(f, 1) == "/") {
            return f
        }
        if (string_length(f) >= 11 && string_copy(f, 1, 11) == "level_data/") {
            return f
        }
        // 模组关卡 JSON 在 datafiles/mods/… 下，与 level_data 并列，不得再加 level_data/ 前缀
        if (string_length(f) >= 5 && string_copy(f, 1, 5) == "mods/") {
            return f
        }
        return "level_data/" + f
    }

    /// @param {String} _path 
    /// @returns {Struct.Result} 
    static load_sound_from_path = function(_path) {
        if (!file_exists(_path)) {
            return new Result().fail(ErrorCode.NO_SUCH_FILE, "File not found: " + _path)
        }
        var _loaded = audio_create_stream(_path);
        if (_loaded == -1) {
            return new Result().fail(ErrorCode.NO_SUCH_FILE, "Failed to load sound: " + _path)
        }
        return new Result().success(_loaded)
    }
}