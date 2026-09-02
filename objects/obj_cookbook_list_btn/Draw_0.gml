draw_self()
draw_set_font(font_yuan)
draw_set_colour(c_black)
draw_set_halign(fa_left)
draw_set_valign(fa_middle)
draw_text(x-230,y-25,cookbook_title)
draw_text(x-230,y+25,desc)

draw_sprite_ext(spr_cookbook_icon,spr_index,x-300,y,1.8,1.8,0,c_white,1)