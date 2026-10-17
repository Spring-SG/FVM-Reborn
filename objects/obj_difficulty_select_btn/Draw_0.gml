draw_self()
draw_set_color(c_white);
draw_set_valign(fa_middle)
draw_set_halign(fa_center)
if config_key == "difficulty"{
	switch state{
		case 0:
			//draw_text(x,y,"美味级")
			tooltip_text = "初始火苗增加150\n敌人血量降低20%"
			break
		case 1:
			//draw_text(x,y,"火山级")
			tooltip_text = "标准的游戏体验"
			break
		case 2:
			//draw_text(x,y,"浮空级")
			tooltip_text = "重新设计的关卡，难度较高"
			break
		case 3:
			//draw_text(x,y,"星际级")
			tooltip_text = "在浮空级的基础上，所有敌人血量增加20%，出怪间隔减半。\n祝你好运！"
			break
	}
	
}
// 在绘制自身之后添加悬停提示
if ((point_in_rectangle(mouse_x, mouse_y, x-hitbox_width/2, y-hitbox_height/2, x+hitbox_width/2, y+hitbox_height/2) ||
		(b_type == "prev" && point_in_rectangle(mouse_x, mouse_y, room_width/2-180, room_height/2, room_width/2+205, room_height/2+160)))
		&& tooltip_text != "") {
	tooltip_set(mouse_x + 15, mouse_y - 15 - string_height(tooltip_text) / 2, tooltip_text, 1, 0.5);
	}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();
