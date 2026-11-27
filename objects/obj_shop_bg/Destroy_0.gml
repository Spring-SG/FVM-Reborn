instance_destroy(obj_closeshop_btn)
instance_destroy(obj_shop_select_btn)
instance_destroy(obj_shop_page_btn)
instance_destroy(obj_shop_buy_btn)
// 菜单状态统一走 scripts/menu_ui：备战房间没有 obj_player_info_ui / obj_world_map_button
menu_ui_reset()

panel_anim_free(id)
if surface_exists(pg_surf) surface_free(pg_surf)   // 页签淡入用的录制面
if surface_exists(pg_old_surf) surface_free(pg_old_surf)   // 交叉淡出的旧内容