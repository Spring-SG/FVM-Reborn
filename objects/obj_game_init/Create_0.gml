function init_native_log() {
    var _local_log_file = global.native_util.get_path_in_local_appdata("\\FVM_Reborn\\native\\latest.log")
	var _error_code = native_set_native_log_file_path(_local_log_file)
	if (_error_code != 0) {
        global.native_util.show_error(_error_code, "设置日志路径失败")
	}

}

function move_files () {
    var _local_folder = global.native_util.get_path_in_local_appdata("\\FVM_Reborn")
    var _saves_old = global.native_util.get_path_in_local_appdata("\\FVM_Reborn\\美食大战老鼠_重生\\saves")
    var _saves_new = global.native_util.get_path_in_local_appdata("\\FVM_Reborn\\saves")
    var _save_folder_new_exists = native_folder_exists(_saves_new)
    var _save_folder_old_exists = native_folder_exists(_saves_old)
    if ((_save_folder_new_exists == 0) && (_save_folder_old_exists == 1)) {
        var _copy_result = native_copy_folder(_saves_old, _local_folder)
        if (_copy_result == 0) {
            show_message_async("存档已自动迁移到[" + _saves_new + "]")
        } else {
            global.native_util.show_error(_copy_result, "存档迁移失败")
        }
    }

    var _local_laboratory = global.native_util.transfer_path_to_windows(working_directory + "laboratory")
    var _local_laboratory_exists = native_folder_exists(_local_laboratory)
    if (_local_laboratory_exists == 1) {
        var _lab_copy_result = native_copy_folder(_local_laboratory, _local_folder)
        if (_lab_copy_result != 0) {
            global.native_util.show_error(_lab_copy_result, "实验室目录迁移失败")
        } else {
            var _lab_delete_result = native_delete_folder(_local_laboratory)
            if (_lab_delete_result != 0) {
                global.native_util.show_error(_lab_delete_result, "旧实验室目录删除失败")
            }
        }
    }
}

global.level = 1
global.menu_screen = true
global.map_name = "美味岛"
global.map_id = "delicious_town"
global.level_id = ""
global.level_file = {}
global.level_name = "曲奇岛"
global.level_data = {}
global.debug = 0
global.laboretory_room = false
global.game_version = "2.4.1"
global.tower_level_click = false
global.tower_cake_page = 1
Music_Init()

global.laboratory_manager = new LaboratoryManager()
global.laboratory_manager.init()
global.gui_stack = new GuiStack()
global.native_util = new NativeUtil()

init_native_log()
move_files()

// 初始化全局键位映射
global.keybind_map = ds_map_create();
// 定义所有快捷键配置
global.keybind_config = [
    {"name": "铲子", "default1": vk_tab, "tooltip": ""},
    {"name": "卡槽1", "default1": ord("1"), "tooltip": ""},
    {"name": "卡槽2", "default1": ord("2"), "tooltip": ""},
    {"name": "卡槽3", "default1": ord("3"), "tooltip": ""},
    {"name": "卡槽4", "default1": ord("4"), "tooltip": ""},
    {"name": "卡槽5", "default1": ord("5"), "tooltip": ""},
    {"name": "卡槽6", "default1": ord("6"), "tooltip": ""},
    {"name": "卡槽7", "default1": ord("7"), "tooltip": ""},
    {"name": "卡槽8", "default1": ord("8"), "tooltip": ""},
    {"name": "卡槽9", "default1": ord("9"), "tooltip": ""},
    {"name": "卡槽10", "default1": ord("0"), "tooltip": ""},
    {"name": "卡槽11", "default1": ord("Q"), "tooltip": ""},
    {"name": "卡槽12", "default1": ord("W"), "tooltip": ""},
	{"name": "卡槽13", "default1": ord("E"), "tooltip": ""},
    {"name": "卡槽14", "default1": ord("R"), "tooltip": ""},
    {"name": "卡槽15", "default1": ord("T"), "tooltip": ""},
    {"name": "卡槽16", "default1": ord("Y"), "tooltip": ""},
    {"name": "卡槽17", "default1": ord("A"), "tooltip": ""},
    {"name": "卡槽18", "default1": ord("S"), "tooltip": ""},
	{"name": "卡槽19", "default1": ord("D"), "tooltip": ""},
    {"name": "卡槽20", "default1": ord("F"), "tooltip": ""},
    {"name": "卡槽21", "default1": ord("G"), "tooltip": ""}
];
//window_set_caption("FVM:Reborn")
// 初始化全局设置（如果不存在配置文件）
if (!file_exists("config.ini")) {
    ini_open("config.ini");
    ini_write_bool("settings", "screen_shake", true);
    ini_write_bool("settings", "screen_flash", true);
	ini_write_bool("settings", "fullscreen", false);
	ini_write_real("settings", "music_volume", 0.7);
	ini_write_real("settings", "sound_volume", 0.7);
	ini_write_bool("settings", "quick_placement", false);
	ini_write_bool("settings", "replace_placement", false);
	ini_write_bool("settings", "card_hpbar", false);
	ini_write_bool("settings", "enemy_hpbar", false);
	ini_write_bool("settings", "tex_fliter", true);
	ini_write_real("settings", "difficulty", 1)
	ini_write_bool("settings", "borderless_window", true);
	ini_write_real("settings", "save_slot", 0)
	ini_write_bool("settings", "lose_focus_pause", true)
	ini_open("config.ini");
    for (var i = 0; i < array_length(global.keybind_config); i++) {
        var kb = global.keybind_config[i];
        ini_write_real("keybinds", kb.name, kb.default1);
    }
    ini_close();
}
// 初始化全局音量变量
global.music_volume_before_mute = 0.7;
global.sound_volume_before_mute = 0.7;

// 读取配置到全局变量
ini_open("config.ini");
global.screen_shake = ini_read_bool("settings", "screen_shake", true);
global.screen_flash = ini_read_bool("settings", "screen_flash", true);
global.fullscreen = ini_read_bool("settings", "fullscreen", false);
global.music_volume = ini_read_real("settings", "music_volume", 0.7);
global.sound_volume = ini_read_real("settings", "sound_volume", 0.7);
global.quick_placement = ini_read_bool("settings", "quick_placement", false);
global.replace_placement = ini_read_bool("settings", "replace_placement", false);
global.card_hpbar = ini_read_bool("settings", "card_hpbar", false);
global.enemy_hpbar = ini_read_bool("settings", "enemy_hpbar", false);
global.tex_fliter = ini_read_bool("settings", "tex_fliter", true);
global.difficulty = ini_read_real("settings", "difficulty", 1)
global.borderless_window = ini_read_bool("settings", "borderless_window", true);
global.save_slot = ini_read_real("settings", "save_slot", 0)
global.lose_focus_pause = ini_read_bool("settings", "lose_focus_pause", true);
global.ime_block = ini_read_bool("settings", "ime_block", true); // 输入法屏蔽开关（个别输入法环境异常时可关）
// 兼容旧配置：键缺失时补写，玩家可手改 %LOCALAPPDATA%\FVM_Reborn\config.ini 关闭
if (ini_read_string("settings", "ime_block", "") == "") {
    ini_write_bool("settings", "ime_block", true);
}

// 鼠标输入限频频率（Hz）：高回报率鼠标掉帧修复。默认 500，设 0 = 完全关闭。
// 兼容旧配置：键缺失时补写，玩家可手改 %LOCALAPPDATA%\FVM_Reborn\config.ini 调整。
// 注意：必须在 ini_open / ini_close 区间内读取，否则会报 INI 文件未定义。
global.mouse_limit_hz = ini_read_real("settings", "mouse_limit_hz", 500);
if (ini_read_string("settings", "mouse_limit_hz", "") == "") {
    ini_write_real("settings", "mouse_limit_hz", 500);
}
for (var i = 0; i < array_length(global.keybind_config); i++) {
	    var kb = global.keybind_config[i];
	    var key_val = ini_read_real("keybinds", kb.name, kb.default1);
	    global.keybind_map[? kb.name] = key_val;
}



ini_close();
audio_group_set_gain(music,global.music_volume,0)
audio_group_set_gain(sound,global.sound_volume,0)
window_set_fullscreen(global.fullscreen)
gpu_set_tex_filter(global.tex_fliter)
window_enable_borderless_fullscreen(global.borderless_window)

// 设置初始静音状态
global.music_volume_before_mute = global.music_volume > 0 ? global.music_volume : 0.7;
global.sound_volume_before_mute = global.sound_volume > 0 ? global.sound_volume : 0.7;

show_debug_message(working_directory)

// 屏蔽输入法（IME）：游戏内全程中文候选框不弹出
if (global.ime_block && native_disable_ime != undefined) {
    native_disable_ime(window_handle());
}

// ═══ 鼠标输入限频（高回报率鼠标掉帧修复）═════════════════════════════════════
// 现象：8 kHz 鼠标在游戏窗口内移动时，draw 阶段单帧阻塞最高 380 ms（fps 降至 2.6），
//       而同期 CPU 占用始终低于 17%，即 runner 在等待而非在计算（step 保持 0.37 ms）。
// 排查：在窗口过程里丢弃消息无法节流（runner 使用自身的 PeekMessage 循环，已实测）；
//       光标合成、raw input、WM_SETCURSOR、独占全屏均已逐个排除。
// 做法：native 侧（mouse_limit.h）使用系统级 WH_MOUSE_LL 钩子，运行在独立线程上；
//       快于目标频率的移动被吞掉且只保留最新位置，再由另一线程按目标频率以 SendInput
//       重新注入。思路与 Ixeris 的 "buffered raw input + threaded event polling" 一致。
// 范围：仅对快于目标频率的输入生效；等于或低于目标频率的鼠标逐条通过，不会变顿。
// 安全：① 仅在游戏窗口处于前台时限频；② 注入线程超过 100 ms 未能注入则全部放行。
// 开关：[settings] mouse_limit_hz（默认 500，0 = 关闭）。该值已在上方
//       ini_open / ini_close 区间读取，此处仅负责启用。
// ═════════════════════════════════════════════════════════════════════════════
if (global.mouse_limit_hz != 0 && native_start_mouse_limit != undefined) {
    native_start_mouse_limit(global.mouse_limit_hz, window_handle());
}
