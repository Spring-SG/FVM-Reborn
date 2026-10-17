// obj_quit_confirm - Step Event
selected_button = -1;

// 检测鼠标交互
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var btn_x = x + btn[0];
    var btn_y = y + btn[4];
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
					obj_camp_shop_bg.is_submenu_opened = false
                    instance_destroy();
                    break;
                    
                case 0: // 确定
                    // 购买逻辑
					obj_camp_shop_bg.is_submenu_opened = false
					with banding_buy_btn{
						if btn_type == "camp"{
							add_material_amount(coin_type,-cost)
							unlock_card(target_item,get_card_info_simple(target_item).level,target_shape,global.save_data.unlocked_items.max_skill_level)
						}
					}
						with obj_camp_shop_bg{
							shop_list_recharge()
						}
					instance_destroy()
                    break;
            }
			global.audio.play(snd_button,0,0)
        }
        break;
    }
}

// ESC键关闭确认窗口
if (keyboard_check_pressed(vk_escape)) {
    instance_destroy();
}