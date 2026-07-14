// Initialize sprite async loader queue
global._loader_sprite_queue = ds_list_create();

// 全局精灵缓存：name → sprite_index
global._sprite_cache = ds_map_create();		// name → real id
global._sprite_is_first = ds_map_create();  // name → bool，标记是否仅加载了第一帧
global._sprite_strips = ds_map_create();    // name → {sprites: [...], fps: N}
global._pid_map = ds_map_create();          // name → placeholder sprite
global._pid_reverse = ds_map_create();      // placeholder sprite → name

/// @function get_load_sprite(_name)
/// @desc 返回占位精灵（空白条带，帧数匹配原精灵），引擎可正常推进 image_index
/// @param {String} _name  精灵名称，如 "spr_blonde_mary_idle"
/// @returns {Real} sprite_index
function get_load_sprite(_name) {
    var _placeholder = global._pid_map[? _name];
    if (is_undefined(_placeholder)) {
        // 从 sprite_data 取帧数，未加载则默认 1
        var _fc = 1;
        if (!is_undefined(global._sprite_data)) {
            var _info = global._sprite_data[$ _name];
            if (!is_undefined(_info)) { _fc = _info.frameCount; }
        }
        // 创建 _fc×1 空白条带精灵
        var _surf = surface_create(_fc, 1);
        surface_set_target(_surf);
        draw_clear_alpha(c_black, 0);
        surface_reset_target();
        var _tmp = working_directory + "_ph_" + _name + ".png";
        surface_save(_surf, _tmp);
        surface_free(_surf);
        _placeholder = sprite_add(_tmp, _fc, false, false, 0, 0);
        file_delete(_tmp);
        ds_map_add(global._pid_map, _name, _placeholder);
        ds_map_add(global._pid_reverse, _placeholder, _name);
        // 同步速度和碰撞盒到占位精灵
        if (!is_undefined(global._sprite_data)) {
            var _info = global._sprite_data[$ _name];
            if (!is_undefined(_info)) {
                // 播放速度
                var _seq = _info[$ "sequence"];
                if (!is_undefined(_seq)) {
                    var _spd = _seq[$ "playbackSpeed"];
                    var _pst = _seq[$ "playbackSpeedType"];
                    if (is_undefined(_spd)) { _spd = _info[$ "fps"]; }
                    if (is_undefined(_pst)) { _pst = 0; }
                    if (!is_undefined(_spd)) {
                        var _speed_type = spritespeed_framespersecond;
                        if (_pst == 1) { _speed_type = spritespeed_secondsperframe; }
                        sprite_set_speed(_placeholder, _spd, _speed_type);
                    }
                }
                // 碰撞遮罩
                var _kind = _info.collisionKind;
                var _bbox = _info.bbox;
                var _tol  = _info[$ "collisionTolerance"];
                if (is_undefined(_tol)) { _tol = 255; }
                var _rtkind = 0;
                switch (_kind) {
                    case 4: _rtkind = 2; break;
                    case 5: _rtkind = 3; break;
                }
                sprite_collision_mask(_placeholder, false, 2, _bbox[0], _bbox[1], _bbox[2], _bbox[3], _rtkind, _tol);
            }
        }
    }
    return _placeholder;
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

    // ── 优先用预合并条带 PNG（depth 版）──
    var _strip_paths = _info[$ "strip_paths"];
    if (!is_undefined(_strip_paths)) {
        var _fps = _info[$ "frames_per_strip"];
        var _total = array_length(_strip_paths);
        var _strips = array_create(_total);
        var _ok = true;
        for (var _si = 0; _si < _total; _si++) {
            var _strip_file = __sprite_manager_find_png(string_replace_all(_strip_paths[_si], "/", "\\"));
            if (!file_exists(_strip_file)) { _ok = false; break; }
            var _seg_fc = (_si == _total - 1) ? _fc - _si * _fps : _fps;
            var _s = sprite_add(_strip_file, _seg_fc, _rmback, _smooth, _xorigin, _yorigin);
            if (_s == -1) { _ok = false; break; }
            _strips[_si] = _s;
        }
        if (_ok) {
            ds_map_add(global._sprite_strips, _name, {sprites: _strips, fps: _fps});
            // 返回第一段作为"主精灵"，单段时正常，多段时 draw_self hook 切段
            __sprite_manager_apply_props(_strips[0], _info);
            return _strips[0];
        }
    }

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
       // file_delete(_tmp_file);
       // file_delete(_tmp_file);
    }

    if (_spr == -1) return -1;
	if _name=="spr_small_fire"{
		var t=0;
	}
    __sprite_manager_apply_props(_spr, _info);
    return _spr;
}

/// @desc 从数据创建只含第一帧的单帧 sprite
/// @param {String} _name  精灵名称
/// @param {Struct} _info  精灵信息
/// @returns {Real} sprite_index，失败返回 -1
function __sprite_manager_build_first_frame(_name, _info) {
    var _xorigin   = _info.xorigin;
    var _yorigin   = _info.yorigin;
    var _smooth    = false;
    var _rmback    = false;

    // ── 优先用预存第一帧 PNG（depth 版）──
    var _first = _info[$ "first_path"];
    if (!is_undefined(_first)) {
        var _first_file = __sprite_manager_find_png(string_replace_all(_first, "/", "\\"));
        if (file_exists(_first_file)) {
            var _spr = sprite_add(_first_file, 1, _rmback, _smooth, _xorigin, _yorigin);
            if (_spr != -1) {
                // 多段条带情况：也初始化 _sprite_strips 以便 draw_self 切段
                var _strip_paths = _info[$ "strip_paths"];
                if (!is_undefined(_strip_paths)) {
                    var _total = array_length(_strip_paths);
                    if (_total > 1) {
                        ds_map_add(global._sprite_strips, _name, {
                            sprites: [_spr],  // 只有第一段
                            fps: _info[$ "frames_per_strip"]
                        });
                    }
                }
                __sprite_manager_apply_props(_spr, _info);
                return _spr;
            }
        }
    }

    // ── 回退：从原始帧目录加载 ──
    var _path      = _info.path;
    var _frames    = _info.frames;
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

/// @desc 根据 .yy 完整数据设置精灵属性：速度、碰撞、九宫格
/// .yy collisionKind → runtime kind 映射:
///   0=自动矩形 → 0(rect)   1=手动矩形 → 0(rect)
///   4=椭圆     → 2(ellipse) 5=菱形    → 3(diamond)
function __sprite_manager_apply_props(_spr, _info) {
    // ── 播放速度（直接从 .yy 原始序列数据读取）──
	_names = global._pid_reverse[? _spr];
	if _spr=="spr_small_fire" or global._pid_reverse[? _spr]=="spr_small_fire"{
		var t=0;
	}
    var _seq = _info[$ "sequence"];

    if (!is_undefined(_seq)) {
        var _spd = _seq[$ "playbackSpeed"];
        var _pst = _seq[$ "playbackSpeedType"];
        if (is_undefined(_spd)) { _spd = _info[$ "fps"]; }
        if (is_undefined(_pst)) { _pst = 0; }
        if (!is_undefined(_spd)) {
            sprite_set_speed(_spr, _spd, _pst);
        }
    }
	
    		
    // ── 碰撞遮罩 ──
    var _kind  = _info.collisionKind;
    var _bbox  = _info.bbox;
    var _bmode = _info[$ "bboxMode"];
    if (is_undefined(_bmode)) _bmode = 0;
    var _tol   = _info[$ "collisionTolerance"];
    if (is_undefined(_tol)) _tol = 255;

    switch (_kind) {
        case 0: // 自动矩形 → runtime rect (kind=0), 沿用 .yy 的 bboxMode
            sprite_collision_mask(_spr, false, _bmode, _bbox[0], _bbox[1], _bbox[2], _bbox[3], 0, _tol);
            break;
        case 1: // 手动矩形 → runtime rect (kind=0), bboxMode=2 手动
            sprite_collision_mask(_spr, false, 2, _bbox[0], _bbox[1], _bbox[2], _bbox[3], 0, _tol);
            break;
        case 4: // 椭圆 → runtime ellipse (kind=2), bboxMode=2 手动使用 .yy bbox 值
            sprite_collision_mask(_spr, false, 2, _bbox[0], _bbox[1], _bbox[2], _bbox[3], 2, _tol);
            break;
        case 5: // 菱形 → runtime diamond (kind=3), bboxMode=2 手动使用 .yy bbox 值
            sprite_collision_mask(_spr, false, 2, _bbox[0], _bbox[1], _bbox[2], _bbox[3], 3, _tol);
            break;
        default:
            sprite_collision_mask(_spr, false, _bmode, _bbox[0], _bbox[1], _bbox[2], _bbox[3], 0, _tol);
            break;
    }
    // ── 九宫格 ──
    // 当前 GMS2 版本 NineSlice struct / sprite_set_nineslice 不可用，暂注释
    /*
    var _nine = _info[$ "nineSlice"];
    if (!is_undefined(_nine) && _nine != undefined) {
        if (is_struct(_nine) || is_method(_nine)) {
            var _nl = _nine[$ "left"];
            if (!is_undefined(_nl)) {
                var _nt = _nine[$ "top"];
                var _nr = _nine[$ "right"];
                var _nb = _nine[$ "bottom"];
                var _ne = _nine[$ "enabled"];
                sprite_set_nineslice(_spr, _nl, _nt, _nr, _nb, _ne != false);
            }
        }
    }
    */

    // ── 预乘 Alpha ──
    // 当前 GMS2 版本无 sprite_set_premultiplied API，暂跳过
    // var _pma = _info[$ "preMultiplyAlpha"];
    // if (!is_undefined(_pma)) {
    //     sprite_set_premultiplied(_spr, _pma);
    // }
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
