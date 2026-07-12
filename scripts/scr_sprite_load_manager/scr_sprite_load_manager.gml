// Initialize sprite async loader queue
global._loader_sprite_queue = ds_list_create();

// 全局精灵缓存：name → sprite_index
global._sprite_cache = ds_map_create();		// name → real id
global._sprite_is_first = ds_map_create();  // name → bool，标记是否仅加载了第一帧
global._pid_next = 100000;                  // 占位 ID 计数器
global._pid_map = ds_map_create();          // name → pid
global._pid_reverse = ds_map_create();      // pid → name

/// @function get_load_sprite(_name)
/// @desc 从缓存中查找已加载的精灵，未加载则返回默认占位精灵
/// @param {String} _name  精灵名称，如 "spr_blonde_mary_idle"
/// @returns {Real} sprite_index
function get_load_sprite(_name) {
    // 永远返回 pid（str ↔ pid 绑定，永不变）
    var _pid = global._pid_map[? _name];
    if (is_undefined(_pid)) {
        _pid = global._pid_next;
        global._pid_next++;
        ds_map_add(global._pid_map, _name, _pid);
        ds_map_add(global._pid_reverse, _pid, _name);
    }
    return _pid;
}

/// @function sprite_manager_init()
/// @desc 读取 removed_sprites.json 和 object_sprite_map.json，构建全局查找表
function sprite_manager_init() {
    // 1. 精灵数据
    var _result = FileUtil.load_json_from_path("removed_sprites.json");
    if (_result.is_failed() == false) {
        global._sprite_data = _result.data;
        // 提取项目根路径（Python 写入的绝对路径兜底）
        global._project_root = global._sprite_data[$ "_project_root"];
        if (is_string(global._project_root)) {
            show_debug_message("[sprite_manager] project root: " + global._project_root);
        }
        var _keys = variable_struct_get_names(global._sprite_data);
        show_debug_message("[sprite_manager] sprite data loaded, " + string(array_length(_keys)) + " sprites");
    } else {
        show_debug_message("[sprite_manager] failed to load removed_sprites.json: " + _result.message);
        global._sprite_data = undefined;
    }

    // 2. 对象→精灵映射，构建反向查找 sprite→object
    var _map_result = FileUtil.load_json_from_path("object_sprite_map.json");
    global._sprite_to_object = ds_map_create();
    if (_map_result.is_failed() == false) {
        global._object_map = _map_result.data;
        var _obj_keys = variable_struct_get_names(global._object_map);
        for (var i = 0; i < array_length(_obj_keys); i++) {
            var _obj_name = _obj_keys[i];
            var _spr_name = global._object_map[$ _obj_name];
            ds_map_add(global._sprite_to_object, _spr_name, _obj_name);
        }
        show_debug_message("[sprite_manager] object map loaded, " + string(array_length(_obj_keys)) + " bindings");
    } else {
        show_debug_message("[sprite_manager] failed to load object_sprite_map.json: " + _map_result.message);
        global._object_map = undefined;
    }
}


/// @function sprite_manager_preview_init()
/// @desc 游戏初始化时调用：加载所有迁移精灵的第一帧，逐帧异步处理
function sprite_manager_preview_init() {
    sprite_manager_init();

    if (is_undefined(global._sprite_data)) {
        show_debug_message("[sprite_manager] preview skipped: no sprite data");
        return;
    }

    // 从 _sprite_data 收集所有精灵名（跳过 _ 开头的元数据）
    var _sprite_list = [];
    var _data_keys = variable_struct_get_names(global._sprite_data);
    for (var i = 0; i < array_length(_data_keys); i++) {
        var _k = _data_keys[i];
        if (string_char_at(_k, 1) == "_") continue;  // 跳过 _project_root 等
        array_push(_sprite_list, _k);
    }

    // 异步加载第一帧
    var _queue = sprite_manager_load_async(_sprite_list, global._sprite_cache, true);
    show_debug_message("[sprite_manager] preview queued: " + string(array_length(_sprite_list)) + " sprites (first frame only)");
}



/// @function sprite_manager_load_first_frame(_list, _map)
/// @desc 遍历 _list 中的精灵名称，只加载每一帧的第一帧为单帧 sprite，将 name→sprite_index 存入 _map
/// @param {Array} _list  精灵名称数组，如 ["spr_blonde_mary_idle", "spr_pixel"]
/// @param {DSMap} _map   存储结果的 ds_map，key=name, value=sprite_index
function sprite_manager_load_first_frame(_list, _map) {
    if (is_undefined(global._sprite_data)) {
        show_debug_message("[sprite_manager] data not loaded, call sprite_manager_init() first");
        return;
    }

    var _sprites = global._sprite_data;
    var _count   = array_length(_list);

    for (var i = 0; i < _count; i++) {
        var _name = _list[i];
        var _info = _sprites[$ _name];

        if (is_undefined(_info)) {
            show_debug_message("[sprite_manager] sprite not found: " + _name);
            continue;
        }

        if (ds_map_exists(_map, _name)) {
            show_debug_message("[sprite_manager] already loaded: " + _name);
            continue;
        }

        var _spr = __sprite_manager_build_first_frame(_name, _info);
        if (_spr != -1) {
            ds_map_add(_map, _name, _spr);
            ds_map_add(global._sprite_cache, _name, _spr);
            __sprite_manager_bind_object(_name, _spr);
            ds_map_add(global._sprite_is_first, _name, true);
            show_debug_message("[sprite_manager] loaded (first frame): " + _name + " -> " + string(_spr));
        }
    }
}


/// @function sprite_manager_load_battle(_list)
/// @desc 战斗开始时调用：异步加载指定精灵的全帧版本，替换已有的首帧
/// @param {Array} _list  精灵名称数组
/// @returns {Struct} 队列 struct
function sprite_manager_load_battle(_list) {
    var _need = [];
    for (var i = 0; i < array_length(_list); i++) {
        var _name = _list[i];
        // 已是全帧，跳过
        if (ds_map_exists(global._sprite_is_first, _name) && !global._sprite_is_first[? _name])
            continue;
        array_push(_need, _name);
    }
    if (array_length(_need) == 0) {
        show_debug_message("[sprite_manager] battle: all already full, nothing to load");
        return undefined;
    }
    var _queue = sprite_manager_load_async(_need, global._sprite_cache, false);
    show_debug_message("[sprite_manager] battle queued: " + string(array_length(_need)) + " sprites (full frames)");
    return _queue;
}

// ─── 异步分帧加载 ──────────────────────────────────────────────────────────

/// @function sprite_manager_load_async(_list, _map, [_first_frame])
/// @desc 创建异步加载队列，每帧由 obj_shell 调用 sprite_manager_async_process_one() 处理一个精灵
/// @param {Array}  _list        精灵名称数组
/// @param {DSMap}  _map         存储结果的 ds_map
/// @param {Bool}   _first_frame 是否只加载第一帧（可选，默认 false）
/// @returns {Struct} 队列 struct，供外部查询进度
function sprite_manager_load_async(_list, _map, _first_frame = false) {
    if (is_undefined(global._sprite_data)) {
        show_debug_message("[sprite_manager] data not loaded, call sprite_manager_init() first");
        return undefined;
    }

    // 过滤掉已在 map 中的和不在数据中的
    var _sprites = global._sprite_data;
    var _pending  = [];
    var _count    = array_length(_list);
    for (var i = 0; i < _count; i++) {
        var _name = _list[i];
        if (ds_map_exists(_map, _name)) {
            // 首帧的允许重新加载全帧
            if (_first_frame || ds_map_exists(global._sprite_is_first, _name) && global._sprite_is_first[? _name] == false) {
                show_debug_message("[sprite_manager] async skip (already loaded): " + _name);
                continue;
            }
        }
        var _info = _sprites[$ _name];
        if (is_undefined(_info)) {
            show_debug_message("[sprite_manager] async skip (not in data): " + _name);
            continue;
        }
        array_push(_pending, _name);
    }

    var _total = array_length(_pending);

    var _queue = {
        list:        _pending,
        map:         _map,
        index:       0,
        total:       _total,
        first_frame: _first_frame,
        done:        (_total == 0),
        loaded:      0,
        failed:      0
    };

    // 确保全局队列存在
    if (is_undefined(global._loader_sprite_queue)) {
        global._loader_sprite_queue = ds_list_create();
    }
    ds_list_add(global._loader_sprite_queue, _queue);

    show_debug_message("[sprite_manager] async queue created, " + string(_total) + " sprites pending");

    return _queue;
}

/// @function sprite_manager_async_process_one(_queue)
/// @desc 处理队列中的下一个精灵（每帧调用一次），由 obj_shell Step_0 驱动
/// @param {Struct} _queue  由 sprite_manager_load_async 返回的队列 struct
/// @returns {Bool} 是否还有剩余待处理项（true = 还有，false = 全部完成）
function sprite_manager_async_process_one(_queue) {
    if (_queue.done) return false;

    var _name = _queue.list[_queue.index];
    var _info = global._sprite_data[$ _name];


    var _spr;
    if (_queue.first_frame) {
        _spr = __sprite_manager_build_first_frame(_name, _info);
    } else {
        _spr = __sprite_manager_build(_name, _info);
    }

    if (_spr != -1) {
		_queue.map[?_name]=_spr;
        global._sprite_is_first[? _name]= _queue.first_frame;
        _queue.loaded++;


        show_debug_message("[sprite_manager] async loaded (" + string(_queue.loaded) + "/" + string(_queue.total) + "): " + _name);
    } else {
        _queue.failed++;
        show_debug_message("[sprite_manager] async failed: " + _name);
    }
    _queue.index++;

    if (_queue.index >= _queue.total) {
        _queue.done = true;
        show_debug_message("[sprite_manager] async complete, loaded=" + string(_queue.loaded) + " failed=" + string(_queue.failed));
        return false;
    }

    return true;
}

// ─── 内部辅助 ──────────────────────────────────────────────────────────────

/// @desc 查找 sprite 对应的 object 并绑定
/// @param {String} _sprite_name  精灵名称
/// @param {Real}  _spr           sprite_index
function __sprite_manager_update_object(_sprite_name) {
    if (is_undefined(global._sprite_to_object)) return;
    var _obj_name = global._sprite_to_object[? _sprite_name];
    if (is_undefined(_obj_name)) return;
    var _obj_index = asset_get_index(_obj_name);
    if (_obj_index == -1) return;
    var _pid = global._pid_map[? _sprite_name];
    if (!is_undefined(_pid)) {
        object_set_sprite(_obj_index, _pid);  // 绑占位 ID，通过 hook 解析
		show_debug_message("[sprite_manager] bound " + _sprite_name + " -> " + _obj_name);
    }
}

/// @desc 从数据创建单个 sprite
/// @param {String} _name  精灵名称
/// @param {Struct} _info  精灵信息
/// @returns {Real} sprite_index，失败返回 -1
function __sprite_manager_build(_name, _info) {
    var _path      = _info.path;
    var _frames    = _info.frames;
    var _fc        = _info.frameCount;
    var _w         = _info.width;
    var _h         = _info.height;
    var _xorigin   = _info.xorigin;
    var _yorigin   = _info.yorigin;
    var _smooth    = false;
    var _rmback    = false;

    var _dir = string_replace_all(_path, "/", "\\");

    // ── 单帧：直接加载 ──
    if (_fc == 1) {
        var _png = __sprite_manager_find_png(_dir + "\\" + _frames[0] + ".png");
        if (!file_exists(_png)) {
            show_debug_message("[sprite_manager] frame missing: " + _png);
            return -1;
        }
        var _spr = sprite_add(_png, 1, _rmback, _smooth, _xorigin, _yorigin);
        if (_spr == -1) return -1;
        __sprite_manager_apply_props(_spr, _info);
        return _spr;
    }

    // ── 多帧：逐帧加载为临时 sprite → surface 单行条带 → 临时文件 → sprite_add ──
    // sprite_add 只认单行水平条带（图像宽/fc=帧宽, 图像高=帧高），多行网格会算错帧宽
    var _max_tex = 16384;
    var _strip_w = _fc * _w;
    if (_strip_w > _max_tex) {
        show_debug_message("[sprite_manager] strip too wide for " + _name + ": " + string(_strip_w) + " > " + string(_max_tex));
        return -1;
    }

    var _surf = surface_create(_strip_w, _h);
    if (!surface_exists(_surf)) {
        show_debug_message("[sprite_manager] surface create failed: " + _name);
        return -1;
    }

    surface_set_target(_surf);
    draw_clear_alpha(c_black, 0);

    var _temp_sprites = [];
    var _ok = true;

    for (var f = 0; f < _fc; f++) {
        var _png = __sprite_manager_find_png(_dir + "\\" + _frames[f] + ".png");
        if (!file_exists(_png)) {
            show_debug_message("[sprite_manager] frame missing: " + _png);
            _ok = false;
            break;
        }

        var _tmp = sprite_add(_png, 1, _rmback, _smooth, 0, 0);
        if (_tmp == -1) {
            show_debug_message("[sprite_manager] load frame failed: " + _png);
            _ok = false;
            break;
        }

        array_push(_temp_sprites, _tmp);
        draw_sprite(_tmp, 0, f * _w, 0);
    }

    surface_reset_target();

    if (!_ok) {
        surface_free(_surf);
        for (var t = 0; t < array_length(_temp_sprites); t++) {
            sprite_delete(_temp_sprites[t]);
        }
        return -1;
    }

    // 保存条带图
    var _tmp_file = working_directory + "_spr_tmp_" + _name + ".png";
    surface_save(_surf, _tmp_file);
    surface_free(_surf);

    // 用条带图创建多帧精灵
    var _spr = sprite_add(_tmp_file, _fc, _rmback, _smooth, _xorigin, _yorigin);

    // 清理临时资源
    for (var t = 0; t < array_length(_temp_sprites); t++) {
        sprite_delete(_temp_sprites[t]);
    }
    if (file_exists(_tmp_file)) {
        file_delete(_tmp_file);
    }

    if (_spr == -1) return -1;

    __sprite_manager_apply_props(_spr, _info);
    return _spr;
}

/// @desc 从数据创建只含第一帧的单帧 sprite
/// @param {String} _name  精灵名称
/// @param {Struct} _info  精灵信息
/// @returns {Real} sprite_index，失败返回 -1
function __sprite_manager_build_first_frame(_name, _info) {
    var _path      = _info.path;
    var _frames    = _info.frames;
    var _xorigin   = _info.xorigin;
    var _yorigin   = _info.yorigin;
    var _smooth    = false;
    var _rmback    = false;

    var _dir = string_replace_all(_path, "/", "\\");
    var _png = __sprite_manager_find_png(_dir + "\\" + _frames[0] + ".png");

    if (!file_exists(_png)) {
        show_debug_message("[sprite_manager] first frame missing: " + _png);
        return -1;
    }

    var _spr = sprite_add(_png, 1, _rmback, _smooth, _xorigin, _yorigin);
    if (_spr == -1) return -1;

    __sprite_manager_apply_props(_spr, _info);
    return _spr;
}

/// @desc 设置碰撞模式和播放速度
function __sprite_manager_apply_props(_spr, _info) {
    var _fps = _info.fps;
    if (_fps > 0) {
        sprite_set_speed(_spr, _fps, spritespeed_framespersecond);
    }

    var _kind = _info.collisionKind;
    var _bbox = _info.bbox;
    var _tol = _info[$ "collisionTolerance"];
    if (is_undefined(_tol)) _tol = 255;

    switch (_kind) {
        case 1: // 矩形
            sprite_collision_mask(_spr, false, 2, _bbox[0], _bbox[1], _bbox[2], _bbox[3], _kind, _tol);
            break;
        case 3: // 精确
            sprite_collision_mask(_spr, true, 0, 0, 0, 0, 0, _kind, _tol);
            break;
        default: // 0=自动 或其他
            sprite_collision_mask(_spr, false, 0, 0, 0, 0, 0, _kind, _tol);
            break;
    }
}

/// @desc 先试相对路径，失败拼绝对路径兜底
function __sprite_manager_find_png(_relative) {
    if (file_exists(_relative)) return _relative;
    if (!is_undefined(global._project_root)) {
        var _abs = global._project_root + _relative;
        if (file_exists(_abs)) return _abs;
    }
    return _relative;
}
