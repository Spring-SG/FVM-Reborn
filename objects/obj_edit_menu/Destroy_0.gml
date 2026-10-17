// 销毁事件
instance_destroy(obj_edit_menu_button);
if (instance_exists(obj_text_input)) {
    instance_destroy(obj_text_input);
}
instance_destroy(obj_save_slot_select_btn)
instance_destroy(obj_player_attire_select_btn)
instance_destroy(obj_update_checker_btn)
if surface_exists(sw_surf) surface_free(sw_surf)

// 释放过渡用的 surface 与子对象登记表（surfaces 不会自己回收）
panel_anim_free(id);
