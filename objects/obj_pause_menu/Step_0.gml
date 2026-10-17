// obj_pause_menu - Step Event
// 检查是否有子菜单打开
submenu_open = instance_exists(obj_config_menu) || instance_exists(obj_quit_confirm) || instance_exists(obj_restart_confirm);

// 如果没有子菜单打开，则处理按钮交互
if (!submenu_open) {
    selected_button = -1;
    
    // 检测鼠标悬停
    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);
    
    for (var i = 0; i < array_length(buttons); i++) {
        var btn = buttons[i];
        var btn_x = menu_x + btn[0];
        var btn_y = menu_y + 120 + btn[4];
        var btn_width = btn[2];
        var btn_height = btn[3];
        
        if (point_in_rectangle(mx, my, 
            btn_x - btn_width/2, btn_y - btn_height/2,
            btn_x + btn_width/2, btn_y + btn_height/2)) 
        {
            selected_button = i;
            
            // 处理按钮点击
            if (mouse_check_button_released(mb_left)) {
                switch (i) {
                    case 0: // 继续游戏
                        panel_anim_close(id);   // 淡出后再销毁
                        global.is_paused = false;
                        global.show_menu = false;
                        break;
                        
                    case 1: // 设置
                        instance_create_depth(menu_x, menu_y, depth-1, obj_config_menu);
                        break;
                        
                    case 2: // 退出游戏
                        instance_create_depth(menu_x, menu_y, depth-1, obj_quit_confirm);
                        break;
					case 3://重新开始
						instance_create_depth(menu_x, menu_y, depth-1, obj_restart_confirm);
                        break;
                }
				global.audio.play(snd_button,0,0)
            }
            break;
        }
    }
    
    
}