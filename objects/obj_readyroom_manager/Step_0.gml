
    if (not audio_is_playing(readyroom_music)) {
        // 停止可能存在的暂停实例
        audio_stop_sound(readyroom_music);
        // 从头开始播放新实例
        global.audio.play(readyroom_music, 0, 0);
    }
if keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right){
	if instance_exists(obj_quit_confirm){
		instance_destroy(obj_quit_confirm)
	}
	else{
		if !is_submenu_open{
			instance_create_depth(room_width / 2,room_height / 2,-100,obj_quit_confirm)
		}
	}
}

// 飞入动画推进（线性：每帧固定位移，到点后由槽位绘制接手）
if fly_active{
	fly_t++
	if fly_t >= fly_dur fly_active = false
}

if instance_exists(obj_quit_confirm) || instance_exists(obj_level_preview){
	is_submenu_open = true
}
else{
	is_submenu_open = false
}

