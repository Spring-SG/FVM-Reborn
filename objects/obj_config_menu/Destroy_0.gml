// 销毁所有创建的实例
if (instance_exists(closemenu_btn)) instance_destroy(closemenu_btn);
if (instance_exists(menu_btn1)) instance_destroy(menu_btn1);
if (instance_exists(menu_btn2)) instance_destroy(menu_btn2);
if (instance_exists(menu_btn3)) instance_destroy(menu_btn3);
if (instance_exists(menu_btn4)) instance_destroy(menu_btn4);

// 销毁设置按钮
for (var i = 0; i < array_length(setting_buttons); i++) {
    if (instance_exists(setting_buttons[i])) {
        instance_destroy(setting_buttons[i]);
    }
}

// 释放过渡用的 surface 与子对象登记表（surfaces 不会自己回收）
panel_anim_free(id);
if surface_exists(pg_surf) surface_free(pg_surf)