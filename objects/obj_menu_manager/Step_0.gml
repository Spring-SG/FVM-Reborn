timer++
if keyboard_check_pressed(vk_escape){
	if instance_exists(obj_config_menu){
		panel_anim_close(obj_config_menu)
		obj_player_info_ui.menu_type = 0
	}
	else if instance_exists(obj_edit_menu){
		panel_anim_close(obj_edit_menu)
		obj_player_info_ui.menu_type = 0
	}
	else if instance_exists(obj_world_map_menu){
		panel_anim_close(obj_world_map_menu)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_package_bg){
		panel_anim_close(obj_package_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_info_island_bg){
		instance_destroy(obj_info_island_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_shop_bg){
		panel_anim_close(obj_shop_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_task_bg){
		panel_anim_close(obj_task_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_craft_bg){
		panel_anim_close(obj_craft_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_cookbook_bg){
		panel_anim_close(obj_cookbook_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_tower_cake_bg){
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
		global.gui_stack.pop()
	}
	else if instance_exists(obj_quit_confirm){
		game_end()
	}
	else{
		instance_create_depth(room_width /2,room_height/2,-20,obj_quit_confirm)
	}
}

pre_load_texture()

// 加载完成后的收尾动画计时（黑滤镜淡出 + LOGO 下移淡出）
if (outro_t >= 0) {
	if (!ui_anim_on(1)) {
		outro_t = -1;                            // 运行中切到等级 0：立刻收掉加载界面
	} else {
		outro_t++;
		if (outro_t > outro_frames) outro_t = -1;   // 跑满即彻底不再绘制
	}
}
