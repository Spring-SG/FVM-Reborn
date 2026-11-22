for(var i = 0;i < array_length(mouse_preview_inst);i++){
	instance_destroy(mouse_preview_inst[i])
}
// 强制清除application_surface，避免上一房间图像残留
// ⚠️ application_surface 可能短暂失效（值为 -1），直接用会抛 surface target does not exist
if (surface_exists(application_surface)){
	surface_set_target(application_surface);
	draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
	surface_reset_target();
}