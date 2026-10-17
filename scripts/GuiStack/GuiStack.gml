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
        room_transition_start(_room)
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

/// @description UI 动效分级：0 = 关闭（全部瞬开瞬关）、1 = 基础（场景/面板层级过渡：房间转场、面板进出场、
///              情报岛二级菜单、加载收尾）、2 = 完全（再加卡牌/UI 手感型微动效：备战房间卡片飞行、时装与难度名
///              滑动、音量条入场与星星滚动、开关回弹、提示框）。设置界面「画面设置」页的三档滑块改的就是它，
///              值存 config.ini 的 [settings] ui_anim。
function ui_anim_level(){
    if (!variable_global_exists("ui_anim")) {
        global.ui_anim = 1        // 还没读到设置时按「基础」，即保留现有表现
    }
    return global.ui_anim
}

/// @description 当前动效等级是否达到 _min（0/1/2）—— 每个动效入口调一次就够了
function ui_anim_on(_min){
    return (ui_anim_level() >= _min)
}

/// @description 场景切换用的全局状态（只在这里创建一次），避免挂在实例变量上出现半套状态
function room_transition_state(){
    if (!variable_global_exists("room_trans")) {
        global.room_trans = {
            mode: 0,          // 0 = 空闲, 1 = 淡出, 2 = 淡入
            room: -1,
            t: 0,             // 秒
            frame: -1,        // 上一次推进的 current_time：多个实例同帧时只算一次
            in_place: false,  // true = 不换房，只在全黑那一刻执行一次动作
            action_fn: undefined,
            action_arg: undefined,
            out_time: 0.22,
            in_time: 0.30,
            color: c_black
        }
    }
    return global.room_trans
}

/// @description 开始一次场景切换：淡出 → 换房 → 淡入。没有遮罩宿主就补一个（常驻的 obj_notice_controller）。
/// @param {Asset.GMRoom} _room
function room_transition_start(_room){
    var _tr = room_transition_state()
    if (!room_exists(_room)) {
        return
    }
    if (!ui_anim_on(1)) {                 // 关闭动效：直接换房，不遮黑
        if (_room != room) { room_goto(_room) }
        return
    }
    // 不丢请求：正在淡出就只改目标；正在淡入就从当前黑度接着压黑
    if (_tr.mode != 1) {
        var _a = room_transition_alpha()
        _tr.mode = 1
        _tr.t = sqrt(clamp(_a, 0, 1)) * _tr.out_time
        show_debug_message("[TRANS] start " + room_get_name(_room) + " （from " + room_get_name(room) + "）")
    }
    _tr.room = _room
    _tr.in_place = false
    _tr.action_fn = undefined
    if (!instance_exists(obj_notice_controller)) {
        instance_create_depth(0, 0, -9900, obj_notice_controller)
    }
}
/// @description 同房间内的过渡：淡出 →（全黑）执行一次动作 → 淡入，不换房。
/// @param {Function} _action_fn 全黑那一刻调用的全局函数（不要用绑定实例的方法，实例那时可能已经销毁）
/// @param {Any} _action_arg 传给它的参数
function room_transition_in_place(_action_fn, _action_arg = undefined){
    var _tr = room_transition_state()
    if (!ui_anim_on(1)) {                 // 关闭动效：立刻执行动作，不做淡出淡入
        if (_action_fn != undefined) { _action_fn(_action_arg) }
        return
    }
    _tr.in_place = true
    _tr.action_fn = _action_fn
    _tr.action_arg = _action_arg
    if (_tr.mode != 1) {
        var _a = room_transition_alpha()
        _tr.mode = 1
        _tr.t = sqrt(clamp(_a, 0, 1)) * _tr.out_time
        show_debug_message("[TRANS] start in-place")
    }
    if (!instance_exists(obj_notice_controller)) {
        instance_create_depth(0, 0, -9900, obj_notice_controller)
    }
}

/// @description 同房间换地图：在全黑那一刻才改全局地图 id（换之前别动，否则过渡期间就被看见）
function map_switch_apply(_d){
    if (_d == undefined) {
        return
    }
    global.map_name = _d.name
    global.map_id   = _d.id
}

/// @description 推进切换（挂在 obj_notice_controller 的 Step 上）
function room_transition_step(){
    var _tr = room_transition_state()
    if (_tr.mode == 0) {
        return
    }
    if (_tr.frame == current_time) {
        return                       // 同一帧只推进一次（万一有多个实例）
    }
    _tr.frame = current_time
    _tr.t += min(delta_time / 1000000, 0.05)   // 单帧最多推进 50ms：换房那一帧会掉帧
    if (_tr.mode == 1) {
        if (_tr.t >= _tr.out_time) {
            _tr.mode = 2
            _tr.t = 0
            if (_tr.in_place) {
                _tr.in_place = false
                var _fn  = _tr.action_fn
                var _arg = _tr.action_arg
                _tr.action_fn  = undefined
                _tr.action_arg = undefined
                show_debug_message("[TRANS] in-place 执行")
                if (_fn != undefined) {
                    _fn(_arg)
                }
            }
            else {
                if (!room_exists(_tr.room)) {
                    show_debug_message("[TRANS] 目标房无效，取消切换 room=" + string(_tr.room))
                    _tr.mode = 0
                    _tr.t = 0
                    return
                }
                show_debug_message("[TRANS] goto " + room_get_name(_tr.room))
                room_goto(_tr.room)
            }
        }
    }
    else if (_tr.t >= _tr.in_time) {
        _tr.mode = 0
        _tr.t = 0
    }
}

/// @description 当前遮罩不透明度（0 = 不画）。非线性：淡入用 ease-in、淡出用 ease-out
function room_transition_alpha(){
    var _tr = room_transition_state()
    if (_tr.mode == 0) {
        return 0
    }
    if (_tr.mode == 1) {
        var _p = clamp(_tr.t / _tr.out_time, 0, 1)
        return _p * _p
    }
    var _p = clamp(_tr.t / _tr.in_time, 0, 1)
    return (1 - _p) * (1 - _p) * (1 - _p)      // 1 → 0（缓出）
}


// ===== UI 动效的唯一接口 ======================================================
// 所有进场/出场/淡入淡出/滑动都走这一套，不要再另起一套状态机。五个槽位：
//
//   ① 门控       ui_anim_on(_min)                每条动效入口调一次；等级 0 / 1 / 2
//   ② 时间+缓动  ui_anim_dt() / ui_anim_ease(_p)  唯一单帧步进 + 唯一曲线
//   ③ 生命周期   panel_anim_init / panel_anim_kids / panel_anim_step /
//                panel_anim_begin / panel_anim_end_slide|end_split|end_parts /
//                panel_anim_close / panel_anim_free
//   ④ 透明度     ui_anim_alpha(_inst) / ui_anim_text_alpha(_inst)
//   ⑤ 场景级     room_transition_start / room_transition_in_place
//
// 实例状态（外部只读，不要直接写）：
//   pnl_o   自己的进度 0~1（0 = 完全收起，1 = 完全展开）
//   pnl_po  父级写进来的进度（顶层恒为 1）
//   => 实际透明度 = pnl_po * pnl_o，任意层数嵌套都成立；ui_anim_alpha() 就是这个乘积
//
// 新动效接入：门控用 ①；计时与缓动用 ui_anim_dt() / ui_anim_ease()；进度写 pnl_o
//            （父级写 pnl_po）—— 其余对象用 ui_anim_alpha() 读，不必知道实现
// =============================================================================

/// @description 唯一单帧步进：delta_time 换成秒并夹住 —— 掉帧那一帧不会让动效一下走完
function ui_anim_dt(){
    return min(delta_time / 1000000, 0.05)
}

/// @description 唯一缓动曲线（ease-out 幂函数）。传 0~1 进度，返回缓动后的 0~1
///              _pow 越大「先快后慢」越明显：3 = 默认 cubic，5 = 前段明显更快
function ui_anim_ease(_p, _pow = 3){
    return 1 - power(1 - clamp(_p, 0, 1), _pow)
}

/// @description 某个实例当前的实际动效透明度（0~1）= 父级进度 × 自己的进度。
///              没参与任何动效的实例返回 1。文字、贴图参数都能用
function ui_anim_alpha(_inst){
    var _a = 1
    if (variable_instance_exists(_inst, "pnl_po")) { _a *= _inst.pnl_po }
    if (variable_instance_exists(_inst, "pnl_o"))  { _a *= _inst.pnl_o }
    return _a
}

/// @description 过渡里的文字透明度：文字不吃 image_alpha，只有 draw_set_alpha 管用。
///              画完记得 draw_set_alpha(1) 复位（别把 alpha 漏给后面的绘制）
function ui_anim_text_alpha(_inst){
    draw_set_alpha(ui_anim_alpha(_inst))
}

// ===== 整块 UI 面板的进出场过渡（商城 / 食神谱 / 合成屋 / 任务 / 背包 / 强化 / 世界地图 共用）=====
// 面板 Draw 里自己如果也有 surface_set_target/reset（成对出现），嵌套是安全的 —— GM 的表面目标是栈。

/// @description 初始化动效状态（对象的 Create 里调一次）
/// @param {Real} _slide 滑动距离（px）
/// @param {Real} _mode  0 = 整块从下方滑入(end_slide)  1 = 左右分半滑入(end_split)
///                      2 = 分区滑入(end_parts)        3 = 只做透明度（不录 surface、不位移）
function panel_anim_init(_inst, _open_time, _close_time, _slide = 260, _mode = 0){
    with (_inst) {
        pnl_open_time  = _open_time
        pnl_close_time = _close_time
        pnl_slide      = _slide
        pnl_mode       = _mode
        pnl_dist       = _slide            // 当前实际滑动距离（end_XXX 每次会同步）
        pnl_split      = 0                 // 分半模式下的接缝（end_split 每次会同步）—— 必须先给初值：
                                           // panel_anim_step 在 Draw 第一行就读它，那时 end_split 还没跑过
        pnl_drawer_dir = -1                // 抽屉模式（mode 4）的拉出方向：-1 = 自左侧，+1 = 自右侧
        pnl_kid_types  = []                // 声明过的「跟着走」的对象（每帧补登记用）
        pnl_t          = 0
        pnl_o          = 0                 // 0 = 收起（全透明+偏移最大），1 = 完全展开
        pnl_po         = 1                 // 父级进度：顶层恒 1，由父级 panel_anim_step 覆写
        pnl_closing    = false
        pnl_surf       = -1
        pnl_recording  = false             // 这一帧是否走 surface 录制（静止时不录，直接画屏幕）
        pnl_parts      = []                // 分区过渡用：[[x1,y1,x2,y2,dx,dy], ...]
        pnl_kids       = ds_list_create()  // [实例, 基准x, 基准y, 基准alpha, 方向]
    }
}

/// @description 登记「跟着一起动」的对象：_things 可以是数组（对象类型 / 实例 id 混放都行），
///              也可以是单个。之后每帧自动补登记 —— 点选项卡才动态创建的子对象不会漏网。
///              对象 Create 里调一次即可
function panel_anim_kids(_inst, _things){
    with (_inst) {
        pnl_kid_types = is_array(_things) ? _things : [_things]
        __panel_anim_collect_kids(id)
    }
}

/// @description 内部：把一个「跟着走」的对象加进表（已登记过则跳过）
function __panel_anim_add_kid(_inst, _kid, _dir = 0){
    with (_inst) {
        if (!variable_instance_exists(id, "pnl_kids")) { pnl_kids = ds_list_create() }
        for (var i = 0; i < ds_list_size(pnl_kids); i += 5) {
            if (pnl_kids[| i] == _kid) { return }        // 已经登记过，别重复加
        }
        // _dir 只在分半模式用：左half 的子对象传 -1，右half 传 +1；只滑不分的面板留 0
        ds_list_add(pnl_kids, _kid, _kid.x, _kid.y, _kid.image_alpha, _dir)
    }
}

/// @description 内部：把「当前活着的那几类对象」补进表（已登记的会跳过）
function __panel_anim_collect_kids(_inst){
    with (_inst) {
        if (!variable_instance_exists(id, "pnl_kid_types")) { return }
        for (var t = 0; t < array_length(pnl_kid_types); t++) {
            var _ty = pnl_kid_types[t]
            with (_ty) { __panel_anim_add_kid(_inst, id) }
        }
    }
}

/// @description 内部：点落在哪个分区里（_parts = [[x1,y1,x2,y2,dx,dy], ...]）；不在任何区返回 -1
function __panel_anim_part_of(_parts, _x, _y){
    if (!is_array(_parts)) { return -1 }
    for (var i = 0; i < array_length(_parts); i++) {
        var _p = _parts[i]
        if (_x >= _p[0] && _x <= _p[2] && _y >= _p[1] && _y <= _p[3]) { return i }
    }
    return -1
}

/// @description 请求关闭：反向播完再销毁（等级 0 或没初始化过就直接销毁）
function panel_anim_close(_inst){
    with (_inst) {
        if (!variable_instance_exists(id, "pnl_closing")) { instance_destroy(); exit }
        if (!ui_anim_on(1)) { instance_destroy(); exit }   // 关闭动效：立刻销毁，不播收缩
        pnl_closing = true
        pnl_t = 0
    }
}

/// @description 推进进度；关闭播完就销毁实例。Step / End Step 末尾调
/// @param {Bool} _sync_kids false = 只推进进度，不接管子对象位置与透明度（自己管子对象时用）
function panel_anim_step(_inst, _sync_kids = true){
    with (_inst) {
        if (!variable_instance_exists(id, "pnl_o")) { return }
        if (_sync_kids) { __panel_anim_collect_kids(id) }   // 动态创建的子对象每帧自动补上
        var _p = 1
        if (!ui_anim_on(1)) {
            pnl_o = 1                       // 关闭动效：不播过渡，永远当作「完全展开」
            pnl_t = 0
        }
        else {
            var _dur = max(pnl_closing ? pnl_close_time : pnl_open_time, 0.0001)
            pnl_t += ui_anim_dt()
            _p = clamp(pnl_t / _dur, 0, 1)
            pnl_o = pnl_closing ? 1 - ui_anim_ease(_p) : ui_anim_ease(_p)
        }
        // mode 3（只做透明度）：自身精灵跟着淡。父级进度也乘进来，和文字口径一致
        if (pnl_mode == 3) { image_alpha = ui_anim_alpha(id) }
        if (_sync_kids && variable_instance_exists(id, "pnl_kids")) {
            var _n = ds_list_size(pnl_kids)
            var _sh = (1 - pnl_o) * pnl_dist
            var _dy = (pnl_mode == 0) ? _sh : 0
            for (var i = 0; i < _n; i += 5) {
                var _k = pnl_kids[| i]
                if (instance_exists(_k)) {
                    _k.pnl_po = pnl_o       // 子对象统一用 ui_anim_alpha() 读，任意层嵌套相乘
                    // 只在过渡进行中接管子对象的位置与透明度；面板完全展开后不再写，
                    // 否则会抹掉子对象自己的逻辑（滚动 y_offset、
                    // 悬停 image_alpha、瀑布流位移）
                    if (pnl_o < 0.999) {
                        if (pnl_mode != 3) {
                            var _bx = pnl_kids[| i+1]
                            var _by = pnl_kids[| i+2]
                            var _kx = _bx
                            var _ky = _by + _dy
                            if (pnl_mode == 1) {
                                var _kd = pnl_kids[| i+4]
                                if (_kd == 0) { _kd = (_bx < pnl_split) ? -1 : 1 }   // 没指定方向的按接缝哪边决定滑向
                                _kx = _bx + _kd * _sh
                            }
                            else if (pnl_mode == 2) {
                                // 分区过渡：子对象按自己的基准点落在哪个区，就跟那个区同向滑
                                var _pt = __panel_anim_part_of(pnl_parts, _bx, _by)
                                if (_pt >= 0) {
                                    _kx = _bx + pnl_parts[_pt][4] * _sh
                                    _ky = _by + pnl_parts[_pt][5] * _sh
                                }
                            }
                            else if (pnl_mode == 4) {
                                // 抽屉式：整块（含子对象）横向拉出
                                _kx = _bx + pnl_drawer_dir * _sh
                            }
                            _k.x = _kx
                            _k.y = _ky
                        }
                        _k.image_alpha = pnl_kids[| i+3] * pnl_o
                    }
                }
            }
        }
        if (ui_anim_on(1) && pnl_closing && _p >= 1) { instance_destroy() }
    }
}

/// @description 开始录制：面板的全部绘制进一张 surface（Draw 事件第一行之前调）
function panel_anim_begin(_inst){
    with (_inst) {
        // 静止（pnl_o = 1）不录：直接画在屏幕上 —— 和「没有过渡」逐像素一致，也没有 surface 合成偏差。
        // 只有正在动（0 <= pnl_o < 1）的那几帧才走 surface 录制 + 贴回。
        pnl_recording = (pnl_o < 0.999)
        if (!pnl_recording) { return }
        if (!surface_exists(pnl_surf)) { pnl_surf = surface_create(room_width, room_height) }
        surface_set_target(pnl_surf)
        draw_clear_alpha(c_black, 0)
    }
}

/// @description 结束录制：整块从下方滑入 + 淡入（Draw 事件最后一行调）
function panel_anim_end_slide(_inst, _dist = undefined){
    with (_inst) {
        var _d = is_undefined(_dist) ? pnl_slide : _dist
        pnl_mode = 0
        pnl_dist = _d
        if (!pnl_recording) { return }      // 静止帧：内容已经直接画在屏幕上了
        surface_reset_target()
        draw_surface_ext(pnl_surf, 0, (1 - pnl_o) * _d, 1, 1, 0, c_white, pnl_o)
    }
}

/// @description 结束录制：整块横向拉出 + 淡入（抽屉式）。_dir = -1 自左侧拉出 / +1 自右侧
function panel_anim_end_drawer(_inst, _dir = -1, _dist = undefined){
    with (_inst) {
        var _d = is_undefined(_dist) ? pnl_slide : _dist
        pnl_mode       = 4
        pnl_drawer_dir = _dir
        pnl_dist       = _d
        if (!pnl_recording) { return }      // 静止帧：内容已经直接画在屏幕上了
        surface_reset_target()
        draw_surface_ext(pnl_surf, _dir * (1 - pnl_o) * _d, 0, 1, 1, 0, c_white, pnl_o)
    }
}

/// @description 结束录制：按素材量出的接缝分左右两半，各自从外侧滑入 + 一起淡入（背包用）
function panel_anim_end_split(_inst, _split, _dist = undefined){
    with (_inst) {
        var _d = is_undefined(_dist) ? pnl_slide : _dist
        pnl_mode = 1
        pnl_dist = _d
        pnl_split = _split
        var _sh = (1 - pnl_o) * _d
        if (!pnl_recording) { return }      // 静止帧：两块本来就画在原位，不需要贴回来
        surface_reset_target()
        // 左半：整体左移 _sh；右半：整体右移 _sh。只影响动画，静止时两块拼回去是完整的。
        draw_surface_part_ext(pnl_surf, 0, 0, _split, room_height, -_sh, 0, 1, 1, c_white, pnl_o)
        draw_surface_part_ext(pnl_surf, _split, 0, room_width - _split, room_height, _split + _sh, 0, 1, 1, c_white, pnl_o)
    }
}

/// @description 结束录制：把面板切成几个矩形分区，每区朝各自方向滑入 + 一起淡入（合成屋用）
///              _parts = [[x1,y1,x2,y2,dx,dy], ...]，dx/dy = 「从哪边来」(-1 / 0 / +1)
function panel_anim_end_parts(_inst, _parts, _dist = undefined){
    with (_inst) {
        var _d = is_undefined(_dist) ? pnl_slide : _dist
        pnl_mode = 2
        pnl_dist = _d
        pnl_parts = _parts
        if (!pnl_recording) { return }      // 静止帧：内容已经直接画在屏幕上了
        var _sh = (1 - pnl_o) * _d
        surface_reset_target()
        for (var i = 0; i < array_length(_parts); i++) {
            var _p = _parts[i]
            draw_surface_part_ext(pnl_surf, _p[0], _p[1], _p[2] - _p[0], _p[3] - _p[1],
                                  _p[0] + _p[4] * _sh, _p[1] + _p[5] * _sh, 1, 1, c_white, pnl_o)
        }
    }
}

/// @description 释放 surface 与子对象表（面板 CleanUp_0 里调）
function panel_anim_free(_inst){
    with (_inst) {
        if (variable_instance_exists(id, "pnl_surf") && surface_exists(pnl_surf)) { surface_free(pnl_surf) }
        if (variable_instance_exists(id, "pnl_kids") && ds_exists(pnl_kids, ds_type_list)) { ds_list_destroy(pnl_kids) }
    }
}
