draw_sprite_ext(spr_battlestart_button_btm,0,x-10,y+70,0.9,0.9,0,c_white,1)
draw_self()
if (not on_click) or instance_exists(obj_quit_confirm) or instance_exists(obj_level_guide_confirm) or deck_slot_count() <= 0{
	draw_sprite_ext(spr_battlestart_text,0,x,y,0.9,0.9,0,c_white,1)
	image_blend = c_white
}
else{
	draw_sprite_ext(spr_battlestart_text,0,x,y,0.9,0.9,0,c_white,1)
	shader_set(hit_effect_2);
	draw_sprite_ext(spr_battlestart_text,0,x,y,0.9,0.9,0,c_yellow,0.2)
	shader_reset();
	
	//image_blend = c_yellow
}