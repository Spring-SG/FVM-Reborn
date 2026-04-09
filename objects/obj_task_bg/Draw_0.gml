draw_set_alpha(0.5);
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

if target_task_index != -1{
	var current_task_save_data = current_task_list[target_task_index]
	var current_task_info = get_task_data(current_task_save_data.id)
	draw_set_font(font_yuan)
	draw_set_colour(c_black)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text(x+300,y-350,current_task_info.title)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_text(x-50,y-310,current_task_info.desc)
	for(var i = 0; i < array_length(current_task_info.requirements);i++){
		draw_text(x-50,y-35+25*i,current_task_info.requirements[i].desc+"（"+string(current_task_save_data.progress[i])+"/"+string(current_task_info.requirements[i].require)+"）")
	}
	for(var i = 0; i < array_length(current_task_info.rewards);i++){
		if current_task_info.rewards[i].type == "item"{
			var item_name = get_material_info(current_task_info.rewards[i].item_id).name
			draw_text(x-50,y+188+25*i,item_name+"（"+string(current_task_info.rewards[i].amount)+"）")
		}
		else if current_task_info.rewards[i].type == "gold"{
			draw_text(x-50,y+188+25*i,"金币（"+string(current_task_info.rewards[i].amount)+"）")
		}
	}
	if current_task_info.single_game{
		draw_set_colour(c_red)
		draw_text(x+60,y-70,"!单局游戏内完成全部任务目标否则重置进度")
	}
	else if current_task_info.oneshot{
		draw_set_colour(c_red)
		draw_text(x+60,y-70,"!任务过程中如果中途退出或游戏失败则重置进度")
	}
}
else{
	draw_set_font(font_yuan)
	draw_set_colour(c_black)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text(x+300,y-350,"请选择一个任务")
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_text(x-50,y-310,"点击左侧选项卡以查看任务。")
}