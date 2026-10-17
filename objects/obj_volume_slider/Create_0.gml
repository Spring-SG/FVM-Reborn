// 滑块属性
star_prev_x = x;    // 星星滚动用：上一帧的位置
spin_angle  = 0;    // 累计旋转角度（度）
image_xscale = 1
image_yscale = 1
volume_type = ""; // "music" 或 "sound"（由创建者设置）
min_x = 0;
max_x = 560; // 滑块移动范围
current_x = min_x + (max_x - min_x) * 0.7; // 默认70%位置
dragging = false;
bar_width = max_x - min_x;
// 设置初始音量值（基于位置）
update_volume();

/// @function update_volume()
// 根据滑块位置计算音量值（0.0 - 1.0）
function update_volume(){
	volume = (current_x - min_x) / bar_width;

	// 更新全局音量
	if (volume_type == "music") {
	    global.music_volume = volume;
	    // 立即应用音乐音量
	    audio_group_set_gain(music,global.music_volume,0)

	} else if (volume_type == "sound") {
	    global.sound_volume = volume;
		audio_group_set_gain(sound,global.sound_volume,0);
	}
}
if (volume_type == "music") {
	    x = min_x + global.music_volume * (max_x - min_x)
	} else if (volume_type == "sound") {
	    x = min_x + global.sound_volume * (max_x - min_x)
	}
/// @function save_volume()
// 保存到配置文件
function save_volume(){
	ini_open("config.ini");
	if (volume_type == "music") {
	    ini_write_real("settings", "music_volume", global.music_volume);
	} else if (volume_type == "sound") {
	    ini_write_real("settings", "sound_volume", global.sound_volume);
	}
	ini_close();
}