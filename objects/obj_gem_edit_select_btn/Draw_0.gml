draw_self()
draw_set_color(c_white)
draw_set_font(font_yuan)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
ui_anim_text_alpha(id)   // 文字不吃 image_alpha，跟着背包面板一起淡
draw_text(x,y,btn_text)
draw_set_alpha(1)