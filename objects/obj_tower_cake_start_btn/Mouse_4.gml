if not obj_tower_cake_bg.is_submenu_opened && is_unlocked{
	if obj_tower_cake_bg.level_select != -1{
		if global.level_id == "tower_cake_35_2" && global.difficulty >= 3 && !global.tower_level_click && !is_level_completed("tower_cake_35_2"){
			instance_create_depth(room_width/2,room_height/2,depth-1,obj_tower_cake_confirm_menu)
			global.tower_level_click = true
			obj_tower_cake_bg.is_submenu_opened = true
		}
		else{
			global.map_id = "tower_cake"
			global.map_name = "魔塔蛋糕"
			global.gui_stack.to(room_ready)
		}
	}
	audio_play_sound(snd_button,0,0)
}