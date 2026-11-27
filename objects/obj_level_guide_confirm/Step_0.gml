// obj_level_guide_confirm - Step Event
selected_button = -1;

if (click_locked){
	pop_anim_step(id)
	exit
}

// 检测鼠标交互
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    var btn_x = x + btn[0] * pop_s;
    var btn_y = y + 70 * pop_s;
    var btn_width = btn[2];
    var btn_height = btn[3];

    if (point_in_rectangle(mx, my,
        btn_x - btn_width/2, btn_y - btn_height/2,
        btn_x + btn_width/2, btn_y + btn_height/2))
    {
        selected_button = i;

        if (mouse_check_button_released(mb_left)) {
            click_locked = true;
            global.audio.play(snd_button, 0, 0);

            switch (i) {
                case 1: // 取消：只关窗，回到选卡页面（本房间）
                    panel_anim_close(id);
                    break;

                case 0: // 确定：交给开始按钮走原来的入场流程（等同于点「开始战斗」）
                    if (instance_exists(obj_battlestart_button)) {
                        obj_battlestart_button.timer = 0;
                        obj_battlestart_button.button_pushed = true;
                    }
                    panel_anim_close(id);
                    break;
            }
            break;
        }
        break;
    }
}

// ESC键关闭确认窗口（等同取消）
if (keyboard_check_pressed(vk_escape)) {
    click_locked = true;
    panel_anim_close(id);
}

// 推进弹出/回缩（GuiStack pop_anim_step）
pop_anim_step(id)