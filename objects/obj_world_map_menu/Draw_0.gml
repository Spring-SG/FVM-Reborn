panel_anim_step(id)                       // 推进过渡（关闭播完会销毁自己）
if (!instance_exists(id)) { exit }         // 已被销毁：这一帧不再画
if global.menu_screen{
        draw_set_alpha(0.5 * ui_anim_alpha(id));       // 遮罩跟着面板一起淡
        draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
        draw_set_alpha(1);
}
panel_anim_begin(id)
draw_self()
draw_sprite_ext(spr_world_map_name,0,x+45,y+30,1.8,1.8,0,c_white,1)
panel_anim_end_slide(id, 260)   // 整块向上滑入 + 淡入；关闭原路返回
