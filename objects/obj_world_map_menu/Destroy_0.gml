panel_anim_free(id)
obj_world_map_button.world_map = 0
if instance_exists(obj_player_info_ui){
	obj_player_info_ui.menu_type = 0
}
if instance_exists(obj_world_map_choose_btn){
	instance_destroy(obj_world_map_choose_btn)
}
if instance_exists(obj_world_map_close_btn){
	instance_destroy(obj_world_map_close_btn)
}
