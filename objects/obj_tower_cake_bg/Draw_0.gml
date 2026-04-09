draw_self()

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_colour(c_white)
draw_set_font(font_yuan)
//绘制一些静态元素
draw_text(x-650,y-415,"关卡列表")
draw_text(x-650,y+495,string(current_page)+"/"+string(total_page))
draw_text(x+605,y-100,"上方放不下的奖励将会显示在这里")
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_text(x-430,y+372,"欢迎来到魔塔蛋糕！在这里，你开始时就拥有大量火苗，但是鼠军数量也\n会极大提升，并且所有的关卡都具有时间限制。不过，通关后也会有转职\n卡片作为奖励。\n尽你最大的努力登顶吧。")

//绘制关卡信息
if level_select != -1{
	draw_text(x+176,y-360,global.level_data.name)
	draw_text(x+176,y-315,(global.level_file.level_time_feature == "night" ? "黑夜":"白天")+"关卡")
	draw_text(x+176,y-270,"争分夺秒")
	draw_text(x+176,y-225,string(floor(global.level_file.time_limit/60))+"分钟")
	
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text(x-50,y+100,"进入关卡以查看详情")

	if !surface_exists(map_surface){
		map_surface = surface_create(510,192)
	}
	surface_set_target(map_surface)
	draw_sprite_ext(global.level_data.level_sprite,0,0,0,0.4,0.4,0,c_white,1)
	surface_reset_target()
	draw_surface(map_surface,x-434,y-380)
}
else{
	draw_text(x+176,y-360,"未选择关卡")
	draw_text(x+176,y-315,"未选择关卡")
	draw_text(x+176,y-270,"未选择关卡")
	draw_text(x+176,y-225,"未选择关卡")
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text(x-50,y+100,"请点击左侧关卡列表以选择关卡")
}

