instance_destroy(obj_closecookbook_btn)
instance_destroy(obj_cookbook_list_btn)
instance_destroy(obj_cookbook_select_btn)
// 菜单状态统一走 scripts/menu_ui：备战房间没有 obj_player_info_ui / obj_world_map_button
menu_ui_reset()

panel_anim_free(id)