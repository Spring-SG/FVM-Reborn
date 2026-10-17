global.audio.play(snd_button,0,0)
if btn_type == "confirm"{
	obj_info_island_bg.view_card_level = obj_info_island_edit_menu.target_current_info[? "level"]
	obj_info_island_bg.view_card_shape = obj_info_island_edit_menu.target_current_info[? "shape"]
	obj_info_island_bg.view_card_skill = obj_info_island_edit_menu.target_current_info[? "skill"]
}
obj_info_island_bg.is_submenu_opened = false
panel_anim_close(obj_info_island_edit_menu)      // 反向淡完再销毁