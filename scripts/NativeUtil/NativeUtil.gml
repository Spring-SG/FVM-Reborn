/// 

function NativeUtil() constructor {

    
    /// @param {String} _path 
    /// @returns {String}
    static get_path_in_local_appdata = function(_path) {
        var _user_profile = environment_get_variable("LOCALAPPDATA")
        return self.transfer_path_to_windows(_user_profile + _path)
    }

    /// @param {String} _rel GML 沙盒相对路径
    /// @returns {String} native 可用的绝对路径
    static to_native_absolute = function(_rel) {
        _rel = string_replace_all(string(_rel), "/", "\\")
        while (string_starts_with(_rel, "\\")) {
            _rel = string_delete(_rel, 1, 1)
        }
        if (string_pos(":", _rel) > 0) {
            return self.transfer_path_to_windows(_rel)
        }
        return self.get_path_in_local_appdata("\\FVM_Reborn\\" + _rel)
    }

    /// @param {String} _path 
    /// @returns {String}
    static transfer_path_to_windows = function(_path) {
        return string_replace(_path, "/", "\\")
    }

    /// @param {Real} _code 
    /// @param {String} _msg 
    static show_error = function(_code, _msg) {
        show_message_async(_msg + "code: " + string(_code))
    }

}