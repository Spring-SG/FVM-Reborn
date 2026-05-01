// 切换状态
	if config_key == "save_slot"{
		if state < 4{
			state ++
		}
		else{
			state = 0
		}
	}
	audio_play_sound(snd_button,0,0)
	// 保存到配置文件
	if (config_key != "") {
	    ini_open("config.ini");
	    ini_write_real("settings", config_key, state);
	    ini_close();
	}

	if (config_key == "save_slot"){
		save_file(global.save_slot)
		global.save_slot = state
		load_file(global.save_slot)
		global.gui_stack.to(room_menu)
	}
