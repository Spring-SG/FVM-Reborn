if !is_unlocked{
	image_blend = c_gray
}
else{
	image_blend = c_white
}
draw_self()
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_colour(image_blend)
draw_set_font(font_number)
draw_set_alpha(image_alpha)      // 文字不吃 image_alpha：瀑布流入场时按钮在淡入，字要跟着一起淡
draw_text(x,y,btn_text)
draw_set_alpha(1)                // 复位，别把 alpha 漏给后面的绘制