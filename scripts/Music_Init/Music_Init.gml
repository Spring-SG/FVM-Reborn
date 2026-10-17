function Music_Init(){
	audio_group_load(music)
	audio_group_load(sound)
}

/// ═══════════════════════════════════════════════════════════════════════════
/// 音效播放管理器（Issue #79）
/// ═══════════════════════════════════════════════════════════════════════════
/// 把「各处直接调 audio_play_sound」收敛为统一入口，由管理器决定某次播放
/// 是否真的发生、以及用多大增益发生。
///
/// 同一帧内大量卡片各自独立调用 audio_play_sound 时，同一个音效会以
///       相同满增益叠放几十层 → 混音总线削波，表现为音量忽大忽小与爆音。
///
/// 三项策略（不限制全局总量，只按"同类音效"限流）：
///   ① 同一音效最小重触发间隔 —— 实际间隔 =
///      clamp(音效自身时长 × gap_ratio, gap_ms, gap_max)
///   ② 同一音效并发上限（same_max）—— 超出丢弃
///   ③ 强度 → 增益（duck）—— 按最近 density_ms 内的触发次数 d 提升增益：
///      单份增益 = min(1.10, 1 + 0.10·(d−1)/d)，无论多密都不超过基准的 1.10 倍
///   ④ 变化度 —— 间隔随机 ±jitter；音高随机 ±vary_pitch，但【只在战斗场景内】生效：
///      菜单/界面里连点按钮时逐声随机会听起来走音，战斗的嘈杂里才有变化度的意义
///
/// ⚠️ 实际间隔 = clamp(时长 × gap_ratio, gap_ms, gap_max)：短音效落在 gap_ms 地板上，
///      长音效按自身时长的一半（上限 gap_max）。叠放厚度上限因此由 gap_ratio 决定
///      （0.5 → 最多约 2 份重叠），② 再兜一层硬上限；间隔内多出来的直接丢弃。
///      也【不设全局并发上限】，其它声音完全不受本管理器影响。
///
/// 放行规则：循环音（_loop != 0）、音乐与长音频（时长 > music_len）、关闭开关时，
///       一律不做任何节流直接播放 —— 音乐绝不能被预算丢掉。
///
/// 用法：global.audio.play(snd[, prio, loop])，返回音效实例 id（被丢弃时返回 -1）。
/// 统计：global.audio.played / dropped（= drop_gap + drop_same + drop_full）可供性能面板读取。
/// 声道池：GM 默认 128 路（audio_channel_num）。不做全局总量限制时，极端弹幕可能占满声道池，
///       此时 audio_play_sound 返回 -1，本管理器计 drop_full 并跳过，不会报错。
///
/// 配置（config.ini 的 [settings]，由 obj_game_init 在 ini 区间内读入，此处只给默认值）：
///   audio_opt_enable / audio_snd_gap_ms / audio_gap_ratio / audio_gap_max / audio_same_max
///   / audio_duck / audio_jitter / audio_density_ms / audio_vary_pitch
/// ═══════════════════════════════════════════════════════════════════════════

global.audio = {};

global.audio.enable     = true;   // 总开关
global.audio.gap_ms     = 20;     // 同一音效最小重触发间隔（毫秒，地板）
global.audio.gap_ratio  = 0.25;    // 间隔 = 音效自身时长 × 该比例（见 ① 说明）
global.audio.gap_max    = 400;    // 间隔上限（毫秒）—— 更长的音效也不会被锁到更稀疏的网格上
global.audio.jitter     = 0.25;   // 最小间隔的随机抖动幅度（±比例），消除"节拍器"感
global.audio.same_max   = 8;     // 同一音效并发上限（唯一的并发限制，无全局总量限制）
global.audio.duck       = true;   // 强度→增益：触发越密越响，单份上限 1.10 倍
global.audio.density_ms = 300;    // 增益用的密度统计窗口（毫秒）
global.audio.vary_pitch = 0.06;   // 音高随机幅度（±比例，0.06 ≈ ±1 个半音）；只在战斗场景内生效
global.audio.music_len  = 3.0;    // 时长超过该值（秒）视为音乐，不节流

global.audio.played     = 0;      // 实际发声次数（含放行）
global.audio.dropped    = 0;      // 被策略丢弃次数（= drop_gap + drop_same + drop_full）
global.audio.drop_gap   = 0;      // ① 因最小重触发间隔被丢
global.audio.drop_same  = 0;      // ② 因同音并发上限被丢
global.audio.drop_full  = 0;      // 声道池耗尽，audio_play_sound 返回 -1
global.audio.live_count = 0;      // 当前在播实例数
global.audio.live       = {};     // { 音效键: [ [实例id, 结束时刻ms], ... ] }
global.audio.last       = {};     // { 音效键: 上次播放时刻ms }
global.audio.asset      = {};     // { 音效键: 音效资产索引 }
global.audio.gain       = {};     // { 音效键: 当前已套用的增益 }
global.audio.hits       = {};     // { 音效键: [最近触发时刻ms, ...] } 只保留 density_ms 窗口内
global.audio.gc_ms      = -1000000;

/// 回收已结束的实例记录；最多每 50ms 做一次，避免每次 play 都全表扫描。
global.audio.__gc = function(_now) {
    if (_now - global.audio.gc_ms < 50) return;
    global.audio.gc_ms = _now;
    var _keys = variable_struct_get_names(global.audio.live);
    for (var _i = 0; _i < array_length(_keys); _i++) {
        var _k = _keys[_i];
        var _arr = global.audio.live[$ _k];
        var _keep = [];
        for (var _j = 0; _j < array_length(_arr); _j++) {
            if (_arr[_j][1] > _now && audio_is_playing(_arr[_j][0])) {
                array_push(_keep, _arr[_j]);
            }
        }
        global.audio.live_count += array_length(_keep) - array_length(_arr);
        global.audio.live[$ _k] = _keep;
        // 密度窗口空了（最近 density_ms 内没有新触发）就把增益收回来，
        // 否则一次爆发之后该音效会被永久放大
        var _h = variable_struct_exists(global.audio.hits, _k) ? global.audio.hits[$ _k] : [];
        var _hk = [];
        for (var _x = 0; _x < array_length(_h); _x++) {
            if (_h[_x] >= _now - global.audio.density_ms) array_push(_hk, _h[_x]);
        }
        global.audio.hits[$ _k] = _hk;
        if (array_length(_hk) == 0 && global.audio.gain[$ _k] != 1) {
            var _asset = global.audio.asset[$ _k];
            if (_asset != undefined) {
                audio_sound_gain(_asset, 1, 0);
                global.audio.gain[$ _k] = 1;
            }
        }
    }
};

/// 统一播放入口。参数与 audio_play_sound 一致（prio / loop 可省略）。
global.audio.play = function(_snd, _prio = 0, _loop = 0) {
    var _len = audio_sound_length(_snd);

    // 音乐 / 长音频 / 循环音 / 关闭开关：完全放行
    if (!global.audio.enable || _loop != 0 || _len > global.audio.music_len) {
        global.audio.played += 1;
        return audio_play_sound(_snd, _prio, _loop);
    }

    var _now = current_time;
    global.audio.__gc(_now);
    var _k = string(_snd);

    // 不设全局并发总量上限：并发只按"同类音效"限流，其它声音一律不受影响。
    var _arr = variable_struct_exists(global.audio.live, _k) ? global.audio.live[$ _k] : [];

    // ②① 同一音效的节流，对所有音效生效：间隔随音效自身时长缩放，上下都有界 ——
    //    实际间隔 = clamp(时长 × gap_ratio, gap_ms, gap_max)
    //    短音效（时长 < 2×gap_ms）落在地板上；长音效按自身时长的一半（上限 gap_max），既不
    //    会被压成固定网格，也不会因为一秒响五次而叠成一团噪音。
    var _len_ms = _len * 1000;
    var _gap_eff = clamp(_len_ms * global.audio.gap_ratio,
                         global.audio.gap_ms, global.audio.gap_max);
    // ② 同一音效并发上限
    if (array_length(_arr) >= global.audio.same_max) {
        global.audio.drop_same += 1;
        global.audio.dropped += 1;
        return -1;
    }
    // ① 最小重触发间隔（带 ±jitter 抖动：固定节奏会被耳朵锁定，抖一下就不像节拍器）
    var _last = variable_struct_exists(global.audio.last, _k) ? global.audio.last[$ _k] : -1000000;
    var _gap_use = _gap_eff * random_range(1 - global.audio.jitter, 1 + global.audio.jitter);
    if (_now - _last < _gap_use) {
        global.audio.drop_gap += 1;
        global.audio.dropped += 1;
        return -1;
    }
    global.audio.last[$ _k] = _now;

    var _id = audio_play_sound(_snd, _prio, 0);
    // 声道池（audio_channel_num，默认 128 路）占满时 audio_play_sound 返回 -1。
    // 这种"根本没播出去"的条目绝不能记进实例表：-1 不是合法音效资产，之后按它设
    // 增益会报 "Index did not map to an existing audio asset"。
    if (_id == -1) {
        global.audio.drop_full += 1;
        global.audio.dropped += 1;
        return -1;
    }
    array_push(_arr, [_id, _now + max(_len, 0.1) * 1000]);
    global.audio.live[$ _k] = _arr;
    global.audio.live_count += 1;
    global.audio.asset[$ _k] = _snd;

    // ③ 强度 → 增益：用【最近 density_ms 内的触发次数】当强度，而不是"当前在播数"
    //    （被 ① 压住后同音在播数长期只有 1~2，看它等于没有强度感）。
    //    g = min(1.10, 1 + 0.10·(d−1)/d) → d=1:1.000 d=2:1.050 d=3:1.067 d=6:1.083
    //    单调递增、渐近 1.10（不可能超过），给混音电平一个硬上限。
    //    按【音效资产】设增益：同音每一份实例都吃同一个值（这正是"同类叠加"要的），
    //    且资产索引永远合法，不会因实例已结束而查表失败。
    var _hits = variable_struct_exists(global.audio.hits, _k) ? global.audio.hits[$ _k] : [];
    var _min_t = _now - global.audio.density_ms;
    var _keep_hits = [];
    for (var _x = 0; _x < array_length(_hits); _x++) {
        if (_hits[_x] >= _min_t) array_push(_keep_hits, _hits[_x]);
    }
    array_push(_keep_hits, _now);
    global.audio.hits[$ _k] = _keep_hits;

    var _d = array_length(_keep_hits);
    var _g = (global.audio.duck && _d > 1)
             ? min(1.10, 1 + 0.10 * (_d - 1) / _d)
             : 1;
    if (_g != global.audio.gain[$ _k]) {
        audio_sound_gain(_snd, _g, 0);
        global.audio.gain[$ _k] = _g;
    }

    // ④ 变化度：只在【战斗场景内】给轻微随机音高。
    //    连点按钮基本都发生在菜单/背包/商城/强化这些界面，而 UI 音效没有战斗的嘈杂垫底，
    //    逐声随机会让连续点击听起来走音、发飘 —— 所以战斗外一律不给音高随机。
    //    判据用 instance_exists(obj_battle)：它不是 persistent，只存在于 room_battle
    //    （项目里已有同样用法：scripts/load_custom_deck/load_custom_deck.gml:22）。
    //    战斗里保留随机：音效密集、环境声多，轻微音高差异反而让重复的命中声不那么腻。
    if (global.audio.vary_pitch > 0 && instance_exists(obj_battle) && audio_is_playing(_id)) {
        audio_sound_pitch(_id, random_range(1 - global.audio.vary_pitch,
                                            1 + global.audio.vary_pitch));
    }

    global.audio.played += 1;
    return _id;
};
