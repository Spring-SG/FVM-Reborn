draw_self()

var card_data = deck_get_card_data(target_card_id,target_shape)
var card_name = "点击领取"//get_plant_shape_data(target_card_id,target_shape)[? "name"]

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_colour(c_white)
draw_set_font(font_yuan)
draw_sprite_ext(card_data[? "sprite"],0,x,y+25,1,1,0,c_white,1)
draw_text(x,y+83,card_name)

// 绘制价格
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_set_font(font_number);
draw_text_ext_transformed(x-12, y+44, string(card_data[? "cost"]),25,1800,1,1,0);
draw_sprite_ext(spr_flame, 0, x-24, y+43, 0.3, 0.3, 0, c_white, 1);
draw_set_font(font_yuan)

if !unlocked{
	draw_set_alpha(0.5)
	draw_set_colour(c_black)
	draw_rectangle(x-sprite_width/2,y-sprite_height/2,x+sprite_width/2,y+sprite_height/2,0)
	draw_set_alpha(1)
}
else if on_click{
	draw_set_alpha(0.5)
	draw_set_colour(c_white)
	draw_rectangle(x-sprite_width/2,y-sprite_height/2,x+sprite_width/2,y+sprite_height/2,0)
	draw_set_alpha(1)
}

//显示悬停提示
if on_click {
	var tooltip_text = card_data[? "description"];
		if (unlocked) tooltip_text += "\n点击获取卡片转职";
		draw_set_font(font_yuan);
		tooltip_set(mouse_x - 15, mouse_y - 15, tooltip_text, -1);
}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();