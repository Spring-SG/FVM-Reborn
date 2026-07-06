// ==================== 动态文件缓存系统 ====================
// 客户端懒加载自定义关卡的图像/音频资源
// 服务端处理文件请求，客户端接收后注册并更新缺省引用
// 只接受当前房间期望的资源，非当前资源直接丢弃

if (!variable_global_exists("file_cache")) {
    global.file_cache = {
        sprites: ds_map_create(),
        audio: ds_map_create(),
        fingerprints: ds_map_create(),
        expected_sprite: "",
        expected_audio: {},
    }
}

// ========== 指纹计算 ==========

function file_cache_compute_fingerprint(_path) {
    if (!file_exists(_path)) return "";
    var _buf = buffer_load(_path);
    var _size = buffer_get_size(_buf);
    var _sample_size = min(_size, 2048);
    var _sample = buffer_base64_encode(_buf, 0, _sample_size);
    buffer_delete(_buf);
    return string(_size) + "_" + _sample;
}

// ========== 文件名处理 ==========

function file_cache_sanitize_name(_name) {
    var _safe = _name;
    if (string_starts_with(_safe, "./")) { _safe = string_copy(_safe, 3, string_length(_safe) - 2); }
    _safe = string_replace_all(string_replace_all(_safe, "/", "_"), "\\", "_");
    return _safe;
}

// ========== 缓存操作 ==========

function file_cache_has_sprite(_name) { return ds_map_exists(global.file_cache.sprites, _name) }
function file_cache_get_sprite(_name) { return global.file_cache.sprites[? _name] }
function file_cache_set_sprite(_name, _spr) { ds_map_add(global.file_cache.sprites, _name, _spr) }
function file_cache_has_audio(_name) { return ds_map_exists(global.file_cache.audio, _name) }
function file_cache_get_audio(_name) { return global.file_cache.audio[? _name] }
function file_cache_set_audio(_name, _aud) { ds_map_add(global.file_cache.audio, _name, _aud) }
function file_cache_get_fingerprint(_name) {
    if (ds_map_exists(global.file_cache.fingerprints, _name))
        return global.file_cache.fingerprints[? _name];
    return "";
}
function file_cache_set_fingerprint(_name, _fp) { ds_map_add(global.file_cache.fingerprints, _name, _fp); }

// ========== 服务端：处理文件请求 ==========

function file_cache_handle_request(_filename, _purpose, _client) {
    if (global.network.mode != "server") return;
    // 客户端发来的是相对路径，解析为房主本地完整路径来读文件，
    // 但发回时用原始相对路径，保证客户端 expected 校验和 relay 缓存能匹配
    var _rel = _filename;
    if (laboratory_path_is_relative(_filename)) {
        _filename = laboratory_resolve_datafile_path(_filename, global._file_cache_json_path);
    }
    if (file_exists(_filename)) {
        var _buf = buffer_load(_filename);
        if (buffer_exists(_buf)) {
            var _size = buffer_get_size(_buf);
            send_message(_client, MSG_TRANSFER_FILE, _rel, _purpose, _size, _buf);
            buffer_delete(_buf);
            show_debug_message("[服务端] 发送文件: " + _filename + " (" + string(_size) + " bytes)");
            return;
        }
    }
    show_debug_message("[服务端] 文件未找到: " + _filename);
}

// ========== 期望文件记录 ==========

function file_cache_set_expected_sprite(_name) {
    global.file_cache.expected_sprite = _name;
}
function file_cache_set_expected_audio(_name, _field) {
    global.file_cache.expected_audio[$ _field] = _name;
}

function file_cache_is_expected(_filename) {
    if (_filename == global.file_cache.expected_sprite) return true;
    var _keys = struct_get_names(global.file_cache.expected_audio);
    for (var _i = 0; _i < array_length(_keys); _i++) {
        if (global.file_cache.expected_audio[$ _keys[_i]] == _filename) return true;
    }
    return false;
}

// ========== 客户端：接收文件 ==========

function file_cache_handle_receive(_filename, _purpose, _size, _data) {
    if (!file_cache_is_expected(_filename)) {
        show_debug_message("[客户端] 丢弃非期望文件: " + _filename);
        return;
    }
	
    if (!directory_exists("cache")) {
        directory_create("cache");
    }
	
	var _safe = _filename;
    if (string_starts_with(_safe, "./")) { _safe = string_copy(_safe, 3, string_length(_safe) - 2); }
    _safe = string_replace_all(string_replace_all(_safe, "/", "_"), "\\", "_");

	var _path = "cache/"+ _safe
	buffer_save(_data, _path);

	//show_message("save file :"+_path)
	
	
    var _fp = file_cache_compute_fingerprint(_path);
    file_cache_set_fingerprint(_filename, _fp);

    if (string_starts_with(_purpose, "music:")) {
        var _field = string_copy(_purpose, 7, string_length(_purpose) - 6);
        var _aud = audio_create_stream(_path);
        if (_aud != -1) {
            file_cache_set_audio(_filename, _aud);
            global.level_data[$ _field] = _aud;
            show_debug_message("[客户端] 音频已注册: " + _filename + " -> " + _field);
        }
    } else {
        var _spr = sprite_add(_path, 1, false, false, 0, 0);
        if (_spr != -1) {
            file_cache_set_sprite(_filename, _spr);
            global.level_data[$ "level_sprite"] = _spr;
            show_debug_message("[客户端] 精灵已注册: " + _filename + " -> level_sprite");
        }
    }
}

// ========== 客户端：懒加载入口 ==========

function file_cache_load_sprite(_name, _default, _fingerprint) {
    // 1. 先查内存缓存
    if (file_cache_has_sprite(_name)) {
        show_debug_message("[客户端] 精灵命中缓存: " + _name);
        return file_cache_get_sprite(_name);
    }
    // 2. 再查本地文件（cache/ 和 laboratory/）
    if (!is_undefined(_fingerprint) && string_length(_fingerprint) > 0) {
        var _safe = file_cache_sanitize_name(_name);
        var _dirs = ["cache", "laboratory"];
        for (var _i = 0; _i < 2; _i++) {
            var _path = _dirs[_i] + "/" + _safe;
            if (file_exists(_path)) {
                var _local_fp = file_cache_compute_fingerprint(_path);
                if (_local_fp == _fingerprint) {
                    var _spr = sprite_add(_path, 1, false, false, 0, 0);
                    if (_spr != -1) {
                        file_cache_set_sprite(_name, _spr);
                        file_cache_set_fingerprint(_name, _fingerprint);
                        show_debug_message("[客户端] 精灵本地命中: " + _path);
                        return _spr;
                    }
                }
            }
        }
    }
    // 3. 缓存和本地都没有，发网络请求
    show_debug_message("[客户端] 精灵使用缺省，请求: " + _name);
    send_message(global.network.server_socket, MSG_REQUEST_FILE, _name, "map_sprite");
    return _default;
}

function file_cache_load_audio(_name, _field, _default, _fingerprint) {
    // 1. 先查内存缓存
    if (file_cache_has_audio(_name)) {
        show_debug_message("[客户端] 音频命中缓存: " + _name);
        return file_cache_get_audio(_name);
    }
    // 2. 再查本地文件（cache/ 和 laboratory/）
    if (!is_undefined(_fingerprint) && string_length(_fingerprint) > 0) {
        var _safe = file_cache_sanitize_name(_name);
        var _dirs = ["cache", "laboratory"];
        for (var _i = 0; _i < 2; _i++) {
            var _path = _dirs[_i] + "/" + _safe;
            if (file_exists(_path)) {
                var _local_fp = file_cache_compute_fingerprint(_path);
                if (_local_fp == _fingerprint) {
                    var _aud = audio_create_stream(_path);
                    if (_aud != -1) {
                        file_cache_set_audio(_name, _aud);
                        file_cache_set_fingerprint(_name, _fingerprint);
                        show_debug_message("[客户端] 音频本地命中: " + _path);
                        return _aud;
                    }
                }
            }
        }
    }
    // 3. 缓存和本地都没有，发网络请求
    show_debug_message("[客户端] 音频使用缺省，请求: " + _name);
    send_message(global.network.server_socket, MSG_REQUEST_FILE, _name, "music:" + _field);
    return _default;
}


// ========== 清空缓存 ==========

function file_cache_clear() {
    ds_map_destroy(global.file_cache.sprites);
    global.file_cache.sprites = ds_map_create();
    ds_map_destroy(global.file_cache.audio);
    global.file_cache.audio = ds_map_create();
    ds_map_destroy(global.file_cache.fingerprints);
    global.file_cache.fingerprints = ds_map_create();

    global.file_cache.expected_sprite = "";
    global.file_cache.expected_audio = {};

    show_debug_message("[客户端] 文件缓存已清空");
}
