// ESC键关闭菜单
    if (keyboard_check_pressed(vk_escape)) {
		if instance_exists(obj_config_menu){
			panel_anim_close(obj_config_menu)
		}
        panel_anim_close(id);   // 淡出后再销毁（原来是瞬间销毁）
        global.is_paused = false;
        global.show_menu = false;
    }