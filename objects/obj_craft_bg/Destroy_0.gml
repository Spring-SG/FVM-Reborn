instance_destroy(obj_closecraft_btn)
instance_destroy(obj_craft_select_btn)
instance_destroy(obj_craft_confirm_btn)
// 菜单状态统一走 scripts/menu_ui：备战房间没有 obj_player_info_ui / obj_world_map_button
menu_ui_reset()
surface_free(card_surface)

panel_anim_free(id)