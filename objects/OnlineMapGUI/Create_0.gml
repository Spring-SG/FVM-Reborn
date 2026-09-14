///
self.state = {
    /// @type {Struct.MapDownloadManager}
    manager: undefined,
    /// @type {Array<Struct.OnlineMapItem>}
    items: [],
    search_query: "",
    status_text: "正在获取地图列表…",
    /// @type {Asset.GMObject.GridList}
    grid_list: undefined,
    /// @type {Asset.GMObject.SearchBox}
    search_box: undefined,
    /// @type {Asset.GMObject.Button}
    close_button: undefined,
    /// @type {Asset.GMObject.OnlineStageDetail}
    detail: undefined,
    /// @type {function}
    on_close: undefined,
    pending: {},
    busy: false,
}

function set_on_close(_on_close) {
    self.state.on_close = _on_close
    return self
}

function track_request(_id, _meta) {
    variable_struct_set(self.state.pending, string(_id), _meta)
}

function take_request(_id) {
    var _key = string(_id)
    if (!variable_struct_exists(self.state.pending, _key)) {
        return undefined
    }
    var _meta = variable_struct_get(self.state.pending, _key)
    variable_struct_remove(self.state.pending, _key)
    return _meta
}

function http_headers() {
    var _headers = ds_map_create()
    ds_map_add(_headers, "User-Agent", "FVM-Reborn")
    ds_map_add(_headers, "Accept", "application/json")
    ds_map_add(_headers, "Accept-Encoding", "identity")
    return _headers
}

function request_json(_url, _method, _meta) {
    var _headers = http_headers()
    var _id = http_request(_url, _method, _headers, "")
    ds_map_destroy(_headers)
    track_request(_id, _meta)
    return _id
}

function find_item(_id) {
    for (var i = 0; i < array_length(self.state.items); i++) {
        if (self.state.items[i].id == _id) {
            return self.state.items[i]
        }
    }
    return undefined
}

function find_item_widget(_id) {
    if (is_undefined(self.state.grid_list)) {
        return undefined
    }
    var _items = self.state.grid_list.state.items
    for (var i = 0; i < array_length(_items); i++) {
        var _inst = _items[i]
        if (instance_exists(_inst) && !is_undefined(_inst.state.item) && _inst.state.item.id == _id) {
            return _inst
        }
    }
    return undefined
}

function apply_downloaded_flag(_item) {
    _item.downloaded = self.state.manager.is_downloaded(_item.title)
    var _widget = find_item_widget(_item.id)
    if (!is_undefined(_widget)) {
        _widget.set_downloaded(_item.downloaded)
    }
    if (!is_undefined(self.state.detail) && instance_exists(self.state.detail) && !is_undefined(self.state.detail.state.item) && self.state.detail.state.item.id == _item.id) {
        self.state.detail.set_item(_item)
    }
}

function rebuild_list() {
    if (is_undefined(self.state.grid_list) || !instance_exists(self.state.grid_list)) {
        return
    }
    self.state.grid_list.destroy_items()
    var _filtered = self.state.manager.filter_items(self.state.items, self.state.search_query)
    var _widgets = []
    for (var i = 0; i < array_length(_filtered); i++) {
        var _item = _filtered[i]
        /// @type {Asset.GMObject.OnlineStageItem}
        var _widget = instance_create_layer(0, 0, "Assets", OnlineStageItem)
        _widget.init(_item)
            .set_on_click(method({open_fn: open_detail}, function(_clicked) {
                open_fn(_clicked)
            }))
            .set_on_action(method({action_fn: handle_item_action}, function(_clicked) {
                action_fn(_clicked)
            }))
            .set_should_correspond(method({gui_state: self.state}, function() {
                return is_undefined(gui_state.detail) || !instance_exists(gui_state.detail)
            }))
        _widget.visible = false
        array_push(_widgets, _widget)
        request_thumb(_item)
    }
    self.state.grid_list.set_items(_widgets)
}

function request_thumb(_item) {
    if (_item.image == "") {
        return
    }
    var _cache = self.state.manager.get_thumb_cache_path(_item.id)
    var _sprite = self.state.manager.load_thumb_sprite(_item.id, _cache)
    if (!is_undefined(_sprite)) {
        _item.thumb_sprite = _sprite
        var _widget = find_item_widget(_item.id)
        if (!is_undefined(_widget)) {
            _widget.set_thumb_sprite(_sprite)
        }
        return
    }
    var _url = self.state.manager.resolve_api_url(_item.image)
    if (_url == "") {
        return
    }
    var _id = http_get_file(_url, _cache)
    track_request(_id, {kind: "thumb", item_id: _item.id, dest: _cache})
}

function open_detail(_item) {
    if (!is_undefined(self.state.detail) && instance_exists(self.state.detail)) {
        return
    }
    /// @type {Asset.GMObject.OnlineStageDetail}
    var _detail = instance_create_layer(0, 0, "Float", OnlineStageDetail)
    _detail.init(_item)
        .set_position((room_width - _detail.get_width()) / 2, (room_height - _detail.get_height()) / 2)
        .set_on_close_clicked(method({gui_state: self.state}, function() {
            gui_state.detail = undefined
        }))
        .set_on_action(method({action_fn: handle_item_action}, function(_clicked) {
            action_fn(_clicked)
        }))
    self.state.detail = _detail
    request_json(kMapApiBase + "/api/items/" + _item.id, "GET", {kind: "detail", item_id: _item.id})
}

function handle_item_action(_item) {
    if (self.state.busy) {
        return
    }
    apply_downloaded_flag(_item)
    if (_item.downloaded) {
        var _code = self.state.manager.delete_download(_item.title)
        if (_code != 0) {
            global.native_util.show_error(_code, "删除地图失败")
            return
        }
        apply_downloaded_flag(_item)
        self.state.status_text = "已删除 " + _item.title
        return
    }
    start_download(_item)
}

function start_download(_item) {
    if (_item.map_file == "") {
        show_message_async("该地图没有可下载的文件")
        return
    }
    if (self.state.manager.is_downloaded(_item.title)) {
        apply_downloaded_flag(_item)
        return
    }
    var _url = self.state.manager.resolve_api_url(_item.map_file)
    var _ext = self.state.manager.extension_from_map_file(_item.map_file)
    var _dest = self.state.manager.get_zip_cache_path(_item.id, _ext)
    self.state.busy = true
    self.state.status_text = "正在下载 " + _item.title + "…"
    var _id = http_get_file(_url, _dest)
    track_request(_id, {kind: "zip", item_id: _item.id, dest: _dest})
}

function finish_download(_item, _dest) {
    var _code = self.state.manager.unzip_to_title(_dest, _item.title)
    self.state.busy = false
    if (_code != 0) {
        global.native_util.show_error(_code, "解压地图失败")
        self.state.status_text = "解压失败"
        return
    }
    apply_downloaded_flag(_item)
    self.state.status_text = "已下载 " + _item.title
    request_json(kMapApiBase + "/api/map-download/" + _item.id, "POST", {kind: "download_count", item_id: _item.id})
}

function request_list() {
    self.state.status_text = "正在获取地图列表…"
    request_json(kMapApiBase + "/api/items", "GET", {kind: "list"})
}

function handle_http() {
    var _id = async_load[? "id"]
    if (!variable_struct_exists(self.state.pending, string(_id))) {
        return
    }
    var _status = async_load[? "status"]
    if (_status == 1) {
        return
    }
    var _meta = take_request(_id)
    if (is_undefined(_meta)) {
        return
    }
    var _http = async_load[? "http_status"]
    var _result = async_load[? "result"]
    if (is_undefined(_result)) {
        _result = ""
    } else {
        _result = string(_result)
    }
    if (_status < 0) {
        if (_meta.kind == "zip") {
            self.state.busy = false
            self.state.status_text = "下载失败 status=" + string(_status) + " http=" + string(_http)
        }
        show_debug_message("[OnlineMap] request failed kind=" + _meta.kind + " status=" + string(_status) + " http=" + string(_http))
        return
    }

    if (_meta.kind == "list") {
        if (_http != 200 && _http != 0) {
            self.state.status_text = "获取列表失败 HTTP " + string(_http)
            show_debug_message("[OnlineMap] list http=" + string(_http) + " body=" + string_copy(_result, 1, 200))
            return
        }
        if (string_length(_result) == 0) {
            self.state.status_text = "获取列表失败：空响应"
            return
        }
        try {
            var _json = json_parse(_result)
            if (!is_struct(_json)) {
                self.state.status_text = "解析失败：根节点不是对象"
                show_debug_message("[OnlineMap] list root type invalid")
                return
            }
            var _raw_items = variable_struct_get(_json, "items")
            self.state.items = []
            if (is_array(_raw_items)) {
                for (var i = 0; i < array_length(_raw_items); i++) {
                    array_push(self.state.items, self.state.manager.item_from_json(_raw_items[i]))
                }
            }
            self.state.status_text = "在线地图 " + string(array_length(self.state.items)) + " 张"
        } catch (_e) {
            self.state.status_text = "解析地图列表失败"
            show_debug_message("[OnlineMap] json_parse failed: " + string(_e))
            show_debug_message("[OnlineMap] body preview: " + string_copy(_result, 1, 300))
            return
        }
        try {
            rebuild_list()
        } catch (_rebuild_e) {
            self.state.status_text = "列表创建失败"
            show_debug_message("[OnlineMap] rebuild_list failed: " + string(_rebuild_e))
        }
        return
    }

    if (_meta.kind == "detail") {
        try {
            var _detail_json = json_parse(_result)
            var _item = find_item(_meta.item_id)
            if (!is_undefined(_item)) {
                var _fresh = self.state.manager.item_from_json(_detail_json)
                _fresh.thumb_sprite = _item.thumb_sprite
                _fresh.downloaded = self.state.manager.is_downloaded(_fresh.title)
                var _idx = 0
                for (var j = 0; j < array_length(self.state.items); j++) {
                    if (self.state.items[j].id == _item.id) {
                        _idx = j
                        break
                    }
                }
                self.state.items[_idx] = _fresh
                if (!is_undefined(self.state.detail) && instance_exists(self.state.detail)) {
                    self.state.detail.set_item(_fresh)
                }
            }
        } catch (_e) {
        }
        return
    }

    if (_meta.kind == "thumb") {
        var _item = find_item(_meta.item_id)
        if (is_undefined(_item)) {
            return
        }
        var _sprite = self.state.manager.load_thumb_sprite(_item.id, _meta.dest)
        if (!is_undefined(_sprite)) {
            _item.thumb_sprite = _sprite
            var _widget = find_item_widget(_item.id)
            if (!is_undefined(_widget)) {
                _widget.set_thumb_sprite(_sprite)
            }
        }
        return
    }

    if (_meta.kind == "zip") {
        var _item = find_item(_meta.item_id)
        if (is_undefined(_item)) {
            self.state.busy = false
            return
        }
        if (_http != 200 && _http != 0) {
            self.state.busy = false
            self.state.status_text = "下载失败 HTTP " + string(_http)
            return
        }
        finish_download(_item, _meta.dest)
        return
    }

    if (_meta.kind == "download_count") {
        try {
            var _count_json = json_parse(_result)
            var _item = find_item(_meta.item_id)
            if (!is_undefined(_item) && variable_struct_exists(_count_json, "downloads")) {
                _item.downloads = _count_json.downloads
            }
        } catch (_e) {
        }
    }
}

function do_close() {
    if (!is_undefined(self.state.on_close)) {
        self.state.on_close()
        return
    }
    instance_destroy()
}

function create_widgets() {
    /// @type {Asset.GMObject.Button}
    var _close_button = instance_create_layer(0, 0, "Float", Button)
    _close_button.set_position(room_width - 170, 60)
        .set_sprite(spr_closemenu_btn)
        .set_scale(1.9)
        .set_frames(0, 1, 2)
        .set_on_click(method(self, do_close))
        .set_should_correspond(method({gui_state: self.state}, function() {
            return is_undefined(gui_state.detail) || !instance_exists(gui_state.detail)
        }))
    self.state.close_button = _close_button

    /// @type {Asset.GMObject.GridList}
    var _grid_list = instance_create_layer(0, 0, "Assets", GridList)
    _grid_list.set_viewport(159, 175, 1550, 600)
        .set_items([])
        .set_should_correspond(method({gui_state: self.state}, function() {
            return is_undefined(gui_state.detail) || !instance_exists(gui_state.detail)
        }))
    self.state.grid_list = _grid_list

    /// @type {Asset.GMObject.SearchBox}
    var _search_box = instance_create_layer(0, 0, "Float", SearchBox)
    _search_box.set_position(280, 108)
        .set_size(520, 42)
        .set_placeholder("搜索在线地图名称或作者")
        .set_on_change(method({gui_state: self.state, rebuild_fn: rebuild_list}, function(_text) {
            gui_state.search_query = _text
            rebuild_fn()
        }))
        .set_should_correspond(method({gui_state: self.state}, function() {
            return is_undefined(gui_state.detail) || !instance_exists(gui_state.detail)
        }))
    self.state.search_box = _search_box
}

function on_create() {
    self.state.manager = new MapDownloadManager()
    create_widgets()
    request_list()
}

function on_step() {
}

function on_draw() {
    scribble(self.state.status_text)
        .align(fa_left, fa_middle)
        .starting_format("font_hei_outline_4dir_black")
        .draw(820, 128)
}

function on_cleanup() {
    if (!is_undefined(self.state.search_box) && instance_exists(self.state.search_box)) {
        self.state.search_box.blur()
        instance_destroy(self.state.search_box)
    }
    if (!is_undefined(self.state.grid_list) && instance_exists(self.state.grid_list)) {
        self.state.grid_list.destroy_items()
        instance_destroy(self.state.grid_list)
    }
    if (!is_undefined(self.state.close_button) && instance_exists(self.state.close_button)) {
        instance_destroy(self.state.close_button)
    }
    if (!is_undefined(self.state.detail) && instance_exists(self.state.detail)) {
        instance_destroy(self.state.detail)
    }
    if (!is_undefined(self.state.manager)) {
        self.state.manager.dispose()
    }
}

on_create()
