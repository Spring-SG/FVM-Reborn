// 菜单走掉之后，把 application_surface 清一次：这个项目里 surface 的清除是透明的，
// 场景没画到的像素会保留上一帧 —— 菜单滑过的地方就留下残影。这里清成不透明黑。
surface_set_target(application_surface);
draw_clear(c_black);
surface_reset_target();

instance_destroy(obj_closeinfo_btn)
instance_destroy(obj_info_island_select_btn)
instance_destroy(obj_info_island_edit_menu)
instance_destroy(obj_info_island_edit_btn)
if instance_exists(obj_package_bg){
	obj_package_bg.is_submenu_opened = false
}
obj_player_info_ui.menu_type = 0
obj_world_map_button.world_map = 0
surface_free(info_surface)