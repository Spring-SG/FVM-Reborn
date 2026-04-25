function move_files () {
    var _user_profile = environment_get_variable("LOCALAPPDATA")
    var _local_folder = global.laboratory_manager.file_util.transfer_path_to_windows( _user_profile + "\\FVM_Reborn")

    var _saves_old = global.laboratory_manager.file_util.transfer_path_to_windows( _user_profile + "\\美食大战老鼠_重生\\saves")
    var _saves_new = global.laboratory_manager.file_util.transfer_path_to_windows( _user_profile + "\\FVM_Reborn\\saves")
    var _save_folder_new_exists = native_folder_exists(_saves_new)
    var _save_folder_old_exists = native_folder_exists(_saves_old)
    if ((_save_folder_new_exists == 0) &&( _save_folder_old_exists == 1)) {
        var _copy_result = native_copy_folder(_saves_old, _local_folder)
        if (_copy_result) {
            show_message_async("存档已自动迁移到[" + _saves_new + "]")
        }
    } 

    show_debug_message("[dir]")
    show_debug_message(working_directory)
    var _local_laboratory = global.laboratory_manager.file_util.transfer_path_to_windows(working_directory + "laboratory")
    var _appdata_laboratory = global.laboratory_manager.file_util.transfer_path_to_windows( _user_profile + "\\FVM_Reborn\\laboratory")
    var _local_laboratory_exists = native_folder_exists(_local_laboratory)
    if (_local_laboratory_exists == 1) {
        var _copy_result = native_copy_folder(_local_laboratory, _local_folder)
        if (_copy_result == 1) {
            show_message_async("资源已自动迁移到[" + _appdata_laboratory + "]")
        }
        native_delete_folder(_local_laboratory)
    } else {
        show_debug_message("无法找到[" + _local_laboratory + "]")
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
Music_Init()

global.laboratory_manager = new LaboratoryManager()
global.laboratory_manager.init()
global.gui_stack = new GuiStack()
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
