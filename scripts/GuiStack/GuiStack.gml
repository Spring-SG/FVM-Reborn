/// 



function GuiStack() constructor {

    /// @type {Array<Asset.GMRoom>} 栈内存 room 索引（与 room_goto 一致）
    self._rooms = []
    static _push_room = function(_room) {
        array_push(self._rooms, _room)
    }

    static _pop_room = function() {
        array_pop(self._rooms)
    }

    /// @param {Asset.GMRoom} _room 
    /// @returns {Bool} 
    static _stack_contains = function(_room) {
        for (var i = 0; i < array_length(self._rooms); i++) {
            if (self._rooms[i] == _room) {
                return true
            }
        }
        return false
    }

    /// @returns {Struct.Result} 
    static _sync_room_after_mutation = function() {
        var _n = array_length(self._rooms)
        if (_n == 0) {
            return new Result().fail(ErrorCode.GUI_INVALID_ROOM, "invalid room index: -1")
        }
        var _room = self._rooms[_n - 1]
        if (_room == room) {
            return new Result().success()
        }
        if (!room_exists(_room)) {
            return new Result().fail(ErrorCode.GUI_INVALID_ROOM, "invalid room index: " + string(_room))
        }
        room_goto(_room)
        return new Result().success()
    }

    /// @description 若栈内已有该 room 则 pop 到该层，否则压入并 room_goto。
    /// @param {Asset.GMRoom} _room 
    /// @returns {Struct.Result} 
    static to = function(_room) {
        if (!room_exists(_room)) {
            return new Result().fail(ErrorCode.GUI_INVALID_ROOM, "invalid room: " + string(_room))
        }
        if (self._stack_contains(_room)) {
            return self.pop_until(_room)
        }
        self._push_room(_room)
        return self._sync_room_after_mutation()
    }

    /// @param {Asset.GMRoom} _fallback_room 
    /// @returns {Struct.Result} 
    static pop = function(_fallback_room = room_menu) {
        if (array_length(self._rooms) == 0) {
            return new Result().fail(ErrorCode.GUI_STACK_EMPTY, "gui stack is empty")
        }
        self._pop_room()
        if (array_length(self._rooms) == 0) {
            self._push_room(_fallback_room)
        }
        return self._sync_room_after_mutation()
    }



    /// @param {Asset.GMRoom} _room 
    /// @returns {Struct.Result} 
    static pop_until = function(_room) {
        while (array_length(self._rooms) > 0 && self._rooms[array_length(self._rooms) - 1] != _room) {
            self._pop_room()
        }
        if (array_length(self._rooms) == 0) {
            if (!room_exists(_room)) {
                return new Result().fail(ErrorCode.GUI_INVALID_ROOM, "invalid room: " + string(_room))
            }
            self._push_room(_room)
        }
        return self._sync_room_after_mutation()
    }

    /// @returns {Asset.GMRoom|Undefined} 当前栈顶 room，空栈为 undefined
    static get_top = function() {
        var _n = array_length(self._rooms)
        if (_n == 0) {
            return undefined
        }
        return self._rooms[_n - 1]
    }
}


