image_xscale = 1.8
image_yscale = 1.8
if flash_value >0{
	
    draw_self()
	shader_set(hit_effect_2);
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,c_white,flash_value/200);
	shader_reset();
	
}
else if is_slowdown{
	image_blend = merge_color(c_white,c_blue,0.5)
	draw_self()
}
else{
	image_blend = c_white
	draw_self()
}
if instance_exists(banding_star_obj){
	banding_star_obj.depth = depth -1
}
if is_frozen{
	draw_sprite_ext(spr_mouse_frozen,0,x,y+95,1.8,1.8,0,c_white,1)
}


