// obj_quit_confirm - Step Event
selected_button = -1;

// 检测鼠标交互
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var btn_x = x + btn[0];
    var btn_y = y + 70;
    var btn_width = btn[2];
    var btn_height = btn[3];
    
    if (point_in_rectangle(mx, my, 
        btn_x - btn_width/2, btn_y - btn_height/2,
        btn_x + btn_width/2, btn_y + btn_height/2)) 
    {
        selected_button = i;
        
        if (mouse_check_button_released(mb_left)) {
            switch (i) {
                case 1: // 取消
					if instance_exists(obj_player_info_ui){
						obj_player_info_ui.menu_type = 0
					}
					if instance_exists(obj_world_map_button){
						obj_world_map_button.world_map = 0
					}
                    instance_destroy();
                    break;
                    
                case 0: // 确定
                    // 退出游戏逻辑
					if instance_exists(obj_player_info_ui){
						obj_player_info_ui.menu_type = 0
					}
					if instance_exists(obj_world_map_button){
						obj_world_map_button.world_map = 0
					}
					if global.menu_screen{
						game_end()
					}
					else{
						if global.map_id == "tower_cake" || global.map_id == "delicious_town"{
							global.map_id = "delicious_island"
							global.map_name = "美味岛"
						}
						global.menu_screen = true
						global.gui_stack.pop()
					}
                    break;
            }
			audio_play_sound(snd_button,0,0)
        }
        break;
    }
}

// ESC键关闭确认窗口
if (keyboard_check_pressed(vk_escape)) {
    instance_destroy();
}