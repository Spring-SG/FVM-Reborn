///
#macro kMapApiBase "https://fvm-reb.top"

function OnlineMapItem() constructor {
    self.id = ""
    self.title = ""
    self.author = ""
    self.description = ""
    self.detail = ""
    self.difficulty = ""
    self.downloads = 0
    self.enemy_types = ""
    self.special_mechanics = ""
    self.image = ""
    self.map_file = ""
    self.upload_time = ""
    self.timestamp = 0
    self.author_desc = ""
    /// @type {Asset.GMSprite|Undefined}
    self.thumb_sprite = undefined
    self.downloaded = false
}

function MapDownloadManager() constructor {
    self.file_util = new FileUtil()
    self.owned_sprites = {}

    /// @returns {String}
    static laboratory_appdata = function() {
        return global.native_util.get_path_in_local_appdata("\\FVM_Reborn\\laboratory")
    }

    /// @param {String} _title
    /// @returns {String}
    static sanitize_title = function(_title) {
        var _name = string(_title)
        var _illegal = ["\\", "/", ":", "*", "?", "\"", "<", ">", "|"]
        for (var i = 0; i < array_length(_illegal); i++) {
            _name = string_replace_all(_name, _illegal[i], "_")
        }
        _name = string_trim(_name)
        if (_name == "") {
            _name = "untitled"
        }
        return _name
    }

    /// @param {String} _title
    /// @returns {String}
    static get_download_folder = function(_title) {
        return self.laboratory_appdata() + "\\download\\" + self.sanitize_title(_title)
    }

    /// @param {String} _rel
    /// @returns {String}
    static resolve_save_absolute = function(_rel) {
        return global.native_util.to_native_absolute(_rel)
    }

    /// @param {String} _title
    /// @returns {String}
    static get_working_download_folder = function(_title) {
        return self.get_download_folder(_title)
    }

    /// @param {String} _title
    /// @returns {Bool}
    static is_downloaded = function(_title) {
        return native_folder_exists(self.get_download_folder(_title)) == 1
            || native_folder_exists(self.get_working_download_folder(_title)) == 1
    }

    /// @param {String} _id
    /// @returns {String}
    static get_thumb_cache_path = function(_id) {
        return self.working_cache_dir("thumbs") + string(_id) + ".png"
    }

    /// @param {String} _id
    /// @param {String} _ext
    /// @returns {String}
    static get_zip_cache_path = function(_id, _ext) {
        if (!string_starts_with(_ext, ".")) {
            _ext = "." + _ext
        }
        return self.working_cache_dir("zips") + string(_id) + _ext
    }

    /// @param {String} _dir
    /// @returns {String}
    static ensure_relative_dir = function(_dir) {
        _dir = string_replace_all(string(_dir), "\\", "/")
        while (string_starts_with(_dir, "/")) {
            _dir = string_delete(_dir, 1, 1)
        }
        if (!string_ends_with(_dir, "/")) {
            _dir += "/"
        }
        var _acc = ""
        var _start = 1
        var _len = string_length(_dir)
        for (var i = 1; i <= _len; i++) {
            if (string_char_at(_dir, i) == "/" || i == _len) {
                var _part = string_copy(_dir, _start, i - _start)
                _start = i + 1
                if (_part == "") {
                    continue
                }
                if (_acc != "") {
                    _acc += "/"
                }
                _acc += _part
                if (!directory_exists(_acc)) {
                    directory_create(_acc)
                }
            }
        }
        return _dir
    }

    /// @param {String} _sub
    /// @returns {String}
    static working_cache_dir = function(_sub) {
        return self.ensure_relative_dir("laboratory/cache/" + _sub)
    }

    /// @param {String} _path
    /// @returns {String}
    static to_windows_path = function(_path) {
        return global.native_util.transfer_path_to_windows(_path)
    }

    /// @param {String} _path
    /// @returns {String}
    static resolve_api_url = function(_path) {
        if (is_undefined(_path) || string(_path) == "") {
            return ""
        }
        _path = string(_path)
        if (string_starts_with(_path, "http://") || string_starts_with(_path, "https://")) {
            return _path
        }
        if (!string_starts_with(_path, "/")) {
            _path = "/" + _path
        }
        return kMapApiBase + _path
    }

    /// @param {String} _map_file
    /// @returns {String}
    static extension_from_map_file = function(_map_file) {
        var _name = filename_ext(string(_map_file))
        if (_name == "") {
            return ".zip"
        }
        return _name
    }

    /// @param {Struct} _json
    /// @param {String} _key
    /// @param {String} _fallback
    /// @returns {String}
    static read_string = function(_json, _key, _fallback) {
        if (!variable_struct_exists(_json, _key)) {
            return _fallback
        }
        var _value = variable_struct_get(_json, _key)
        if (is_undefined(_value) || _value == pointer_null) {
            return _fallback
        }
        return string(_value)
    }

    /// @param {Struct} _json
    /// @param {String} _key
    /// @param {Real} _fallback
    /// @returns {Real}
    static read_real = function(_json, _key, _fallback) {
        if (!variable_struct_exists(_json, _key)) {
            return _fallback
        }
        var _value = variable_struct_get(_json, _key)
        if (is_undefined(_value) || _value == pointer_null || _value == "") {
            return _fallback
        }
        return real(_value)
    }

    /// @param {Struct} _json
    /// @returns {Struct.OnlineMapItem}
    static item_from_json = function(_json) {
        var _item = new OnlineMapItem()
        if (!is_struct(_json)) {
            return _item
        }
        _item.id = self.read_string(_json, "id", "")
        _item.title = self.read_string(_json, "title", "")
        _item.author = self.read_string(_json, "author", "")
        _item.description = self.read_string(_json, "description", "")
        _item.detail = self.read_string(_json, "detail", "")
        _item.difficulty = self.read_string(_json, "difficulty", "")
        _item.downloads = self.read_real(_json, "downloads", 0)
        _item.enemy_types = self.read_string(_json, "enemy_types", "")
        _item.special_mechanics = self.read_string(_json, "special_mechanics", "")
        _item.image = self.read_string(_json, "image", "")
        _item.map_file = self.read_string(_json, "map_file", "")
        _item.upload_time = self.read_string(_json, "upload_time", "")
        _item.timestamp = self.read_real(_json, "timestamp", 0)
        _item.author_desc = self.read_string(_json, "author_desc", "")
        _item.downloaded = self.is_downloaded(_item.title)
        return _item
    }

    /// @param {Array<Struct.OnlineMapItem>} _items
    /// @param {String} _query
    /// @returns {Array<Struct.OnlineMapItem>}
    static filter_items = function(_items, _query) {
        var _q = string_lower(string_trim(string(_query)))
        if (_q == "") {
            return _items
        }
        var _out = []
        for (var i = 0; i < array_length(_items); i++) {
            var _item = _items[i]
            var _name = string_lower(string(_item.title))
            var _author = string_lower(string(_item.author))
            if (string_pos(_q, _name) > 0 || string_pos(_q, _author) > 0) {
                array_push(_out, _item)
            }
        }
        return _out
    }

    /// @param {String} _id
    /// @param {String} _path
    /// @returns {Asset.GMSprite|Undefined}
    static load_thumb_sprite = function(_id, _path) {
        if (file_exists(_path)) {
            var _cached = variable_struct_get(self.owned_sprites, _id)
            if (!is_undefined(_cached) && sprite_exists(_cached)) {
                return _cached
            }
            var _result = self.file_util.load_sprite_from_path(_path)
            if (_result.is_succeed()) {
                variable_struct_set(self.owned_sprites, _id, _result.data)
                return _result.data
            }
        }
        return undefined
    }

    /// @param {String} _title
    /// @returns {Real}
    static delete_download = function(_title) {
        var _code = 0
        var _folder = self.get_download_folder(_title)
        if (native_folder_exists(_folder) == 1) {
            _code = native_delete_folder(_folder)
        }
        var _working = self.get_working_download_folder(_title)
        if (native_folder_exists(_working) == 1) {
            var _working_code = native_delete_folder(_working)
            if (_code == 0) {
                _code = _working_code
            }
        }
        return _code
    }

    /// @param {String} _zip_path
    /// @param {String} _title
    /// @returns {Real}
    static unzip_to_title = function(_zip_path, _title) {
        var _zip = global.native_util.to_native_absolute(_zip_path)
        var _dest = self.get_download_folder(_title)
        show_debug_message("[OnlineMap] unzip " + _zip + " -> " + _dest)
        return native_unzip_map_file(_zip, _dest)
    }

    static dispose = function() {
        var _keys = variable_struct_get_names(self.owned_sprites)
        for (var i = 0; i < array_length(_keys); i++) {
            var _spr = variable_struct_get(self.owned_sprites, _keys[i])
            if (sprite_exists(_spr)) {
                sprite_delete(_spr)
            }
        }
        self.owned_sprites = {}
    }
}
