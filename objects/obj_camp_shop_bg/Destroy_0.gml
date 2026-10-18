instance_destroy(obj_closecampshop_btn)
instance_destroy(obj_camp_shop_page_btn)
instance_destroy(obj_camp_shop_buy_btn)
instance_destroy(obj_sold_out_icon)
obj_player_info_ui.menu_type = 0
obj_world_map_button.world_map = 0
if surface_exists(pg_surf) surface_free(pg_surf)
if surface_exists(pg_old_surf) surface_free(pg_old_surf)
panel_anim_free(id)
