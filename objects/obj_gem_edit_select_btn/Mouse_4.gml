global.audio.play(snd_button,0,0)
if btn_type == "confirm"{
	var info_index = obj_gem_edit_menu.target_card_index
	var egg = irandom_range(1,100)
	if egg <= 2{
		if global.save_data.unlocked_gems[info_index].level > 5{
			global.save_data.unlocked_gems[info_index].level -= 1
			
			
		}
		show_notice("不够好运，升级失败！",60)
	}
	else {
		global.save_data.unlocked_gems[info_index].level = obj_gem_edit_menu.target_current_info
	}
	
	
	save_file(0)
}
else if btn_type == "apply"{
	var length = array_length(global.save_data.unlocked_gems)
	var info_index = 0
	var egg = irandom_range(1,100)
	if egg <= 2{
		for (var i = 0;i < length;i++){
			if global.save_data.unlocked_gems[i].level>5{
				global.save_data.unlocked_gems[i].level -= 1
			}
		}
		show_notice("不够好运，升级失败！",60)
	}
	else{
		for (var i = 0;i < length;i++){
			if obj_gem_edit_menu.target_current_info <= global.save_data.unlocked_gems[i].max_level{
				global.save_data.unlocked_gems[i].level = obj_gem_edit_menu.target_current_info
			}
			else{
				global.save_data.unlocked_gems[i].level = global.save_data.unlocked_gems[i].max_level
			}
		}
	}
	
	
	save_file(0)
}
obj_package_bg.is_submenu_opened = false
panel_anim_close(obj_gem_edit_menu)      // 反向淡完再销毁