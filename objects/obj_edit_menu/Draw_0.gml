panel_anim_step(id)
if (!instance_exists(id)) { exit }

if global.menu_screen{
	draw_set_alpha(0.5 * ui_anim_alpha(id));
	draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
}
panel_anim_begin(id)
draw_self()
draw_sprite(spr_edit_menu_bg_2,0,x,y+50)
draw_set_font(font_yuan)
draw_set_color(c_white)
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
//draw_text_ext_transformed(x,y-325,"信息编辑",0,900,2,2,0)

// 绘制标签
draw_set_font(font_yuan);
draw_set_halign(fa_left);
//draw_text(x - 320, y - 175, "角色名:");
//draw_text(x - 320, y - 95, "存档槽位:");
//draw_text(x - 320, y + 15, "角色时装");
draw_text(x - 450, y + 175, "检查更新");

if selected_attire_index != -1{
	selected_attire_id = player_attire_id_list[selected_attire_index]
}
if sw_t < 0{
	edit_attire_content_draw(selected_attire_index, 0, 0)
}
else{
	// 窗口内左右滑动：旧的一档滑出、新的一档自另一侧滑入（窗口外用 surface 裁掉）
	var _p     = sw_t / sw_frames
	var _e     = 1 - (1 - _p) * (1 - _p) * (1 - _p)
	var _shift = sw_win_w * _e
	if !surface_exists(sw_surf) sw_surf = surface_create(sw_win_w, sw_win_h)
	if !surface_exists(sw_surf){
		// surface 建不出来（最小化等极端情况）就退回静态绘制，不在这里中断
		edit_attire_content_draw(selected_attire_index, 0, 0)
	}
	else{
		surface_set_target(sw_surf)
		draw_clear_alpha(c_black, 0)
		edit_attire_content_draw(sw_from,  -sw_dir * _shift - sw_win_l, -sw_win_t)
		edit_attire_content_draw(sw_shown,  sw_dir * (sw_win_w - _shift) - sw_win_l, -sw_win_t)
		surface_reset_target()
		draw_surface_part(sw_surf, 0, 0, sw_win_w, sw_win_h, sw_win_l, sw_win_t)
	}
}

panel_anim_end_slide(id, 260)
