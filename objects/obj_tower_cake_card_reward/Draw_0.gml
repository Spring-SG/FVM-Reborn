draw_self()

var card_data = deck_get_card_data(target_card_id,target_shape)
var card_name = "奖励"+string(btn_index)//get_plant_shape_data(target_card_id,target_shape)[? "name"]

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
draw_set_font(font_yuan);
draw_text_ext_transformed(x-12, y+40, string(card_data[? "cost"]),25,1800,1,1,0);
draw_sprite_ext(spr_flame, 0, x-24, y+43, 0.3, 0.3, 0, c_white, 1);

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
	// 获取鼠标位置
	var tooltip_x = mouse_x - 15;
	var tooltip_y = mouse_y - 15;
            
	// 获取提示文本
            
	var tooltip_text = ""
            
	tooltip_text = card_data[? "description"]
	if unlocked{
		tooltip_text += "\n点击获取卡片转职"
	}
            
			
	// 绘制提示背景
	draw_set_font(font_yuan)
	draw_set_color(c_black);
	draw_set_alpha(0.7);
	draw_rectangle(tooltip_x - string_width(tooltip_text) - 5, tooltip_y - 5, 
	                tooltip_x +5, tooltip_y + string_height(tooltip_text)+5, false);
	//绘制提示文本
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
}