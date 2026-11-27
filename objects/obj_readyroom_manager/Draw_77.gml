if (surface_exists(slot_surface)){
	surface_set_target(slot_surface);
	draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
	surface_reset_target();
}
if (surface_exists(map_surface)){
	surface_set_target(map_surface);
	draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
	surface_reset_target();
}