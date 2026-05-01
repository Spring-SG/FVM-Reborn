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
					obj_shop_bg.is_submenu_opened = false
                    instance_destroy();
                    break;
                    
                case 0: // 确定
                    // 购买逻辑
					obj_shop_bg.is_submenu_opened = false
					with banding_buy_btn{
						if btn_type == "card"{
							global.save_data.player.gold -= cost
							unlock_card(target_item,0,0,global.save_data.unlocked_items.max_skill_level)
						}
						else if btn_type == "weapon"{
							global.save_data.player.gold -= cost
							unlock_weapon(target_item)
						}
						else if btn_type == "gem"{
							global.save_data.player.gold -= cost
							unlock_gem(target_item)
						}
						else if btn_type == "attire"{
							global.save_data.player.gold -= cost
							unlock_attire(target_item)
						}
						else if btn_type == "item"{
							global.save_data.player.gold -= cost
							if target_item == "card_slot" && global.save_data.unlocked_items.max_slot < 18{
								global.save_data.unlocked_items.max_slot += 1
							}
							else if target_item == "card_slot_19" && global.save_data.unlocked_items.max_slot == 18{
								global.save_data.unlocked_items.max_slot += 1
							}
							else if target_item == "card_slot_20" && global.save_data.unlocked_items.max_slot == 19{
								global.save_data.unlocked_items.max_slot += 1
							}
							else if target_item == "card_slot_21" && global.save_data.unlocked_items.max_slot == 20{
								global.save_data.unlocked_items.max_slot += 1
							}
							save_file(global.save_slot)
						}
					}
						with obj_shop_bg{
							shop_list_recharge()
						}
					instance_destroy()
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