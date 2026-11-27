instance_destroy(obj_closepackage_btn)
instance_destroy(obj_packageselect_btn)
instance_destroy(obj_card_edit_menu)
instance_destroy(obj_gem_edit_menu)
// 菜单状态统一走 scripts/menu_ui：备战房间没有 obj_player_info_ui / obj_world_map_button
menu_ui_reset()
if surface_exists(package_surface){
	surface_free(package_surface)
}

panel_anim_free(id)