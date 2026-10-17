// 瀑布流入场：底板 / 文字 / 图标一起从下方滑上来淡入（wf_off、wf_a 由 Step_2 推进）
draw_sprite_ext(sprite_index, image_index, x, y + wf_off, image_xscale, image_yscale, image_angle,
                c_white, image_alpha * wf_a)
draw_set_font(font_yuan)
draw_set_colour(c_black)
draw_set_halign(fa_left)
draw_set_valign(fa_middle)
// 文字不吃 image_alpha：面板过渡 × 瀑布流 两层透明度相乘
draw_set_alpha(ui_anim_alpha(id) * wf_a)
draw_text(x-230, y - 25 + wf_off, cookbook_title)
draw_text(x-230, y + 25 + wf_off, desc)
draw_set_alpha(1)

draw_sprite_ext(spr_cookbook_icon, spr_index, x - 300, y + wf_off, 1.8, 1.8, 0, c_white, image_alpha * wf_a)
