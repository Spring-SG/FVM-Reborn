instance_destroy(obj_closeshop_btn)
instance_destroy(obj_shop_select_btn)
instance_destroy(obj_shop_page_btn)
instance_destroy(obj_shop_buy_btn)
obj_player_info_ui.menu_type = 0
obj_world_map_button.world_map = 0

panel_anim_free(id)
if surface_exists(pg_surf) surface_free(pg_surf)   // 页签淡入用的录制面
