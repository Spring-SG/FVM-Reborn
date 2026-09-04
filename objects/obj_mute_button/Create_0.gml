image_xscale = 1
image_yscale = 1
volume_type = ""; // "music" 或 "sound"（由创建者设置）
image_speed = 0;
on_click = false
update_sprite(on_click);

/// @function update_sprite()
// 根据音量状态更新精灵帧
function update_sprite(is_on_click){
	if (volume_type == "music") {
	    image_index = (global.music_volume == 0) ? 1 : 0;
	} else if (volume_type == "sound") {
	    image_index = (global.sound_volume == 0) ? 1 : 0;
	}
}