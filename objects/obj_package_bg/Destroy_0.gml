instance_destroy(obj_closepackage_btn)
instance_destroy(obj_packageselect_btn)
instance_destroy(obj_card_edit_menu)
instance_destroy(obj_gem_edit_menu)
obj_player_info_ui.menu_type = 0
obj_world_map_button.world_map = 0
if surface_exists(package_surface){
	surface_free(package_surface)
}

panel_anim_free(id)
