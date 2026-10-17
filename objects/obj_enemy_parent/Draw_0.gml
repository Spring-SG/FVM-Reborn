
if(climb_stage==1){
	y = climb_y
}
draw_self()
if flash_value >0{
	
	shader_set(shader_hit);
	draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,flash_color,flash_value/200);
	shader_reset();
	//draw_self()
	//var progress = 1 - flash_value / 150 // 计算进度
    
    //// 设置混合模式为加法混合
    //gpu_set_blendmode(bm_add);
    
    //// 启用Shader
    
    //shader_set_uniform_f(u_progress, progress);
    //shader_set_uniform_f(u_flashColor, flash_color[0], flash_color[1], flash_color[2]);
	//shader_set(shader_hit);
    
    //// 只绘制精灵的非透明部分
    //draw_self();
    
    //// 重置渲染状态
    //shader_reset();
    //gpu_set_blendmode(bm_normal);
}
if is_slowdown{
	image_blend = merge_color(c_white,c_blue,0.5)
	//draw_self()
}
else{
	image_blend = c_white
	//draw_self()
}

if is_frozen{
	draw_sprite_ext(ice_sprite,0,x,y+50,1.8,1.8,0,c_white,1)
}
if is_scare{
	draw_sprite_ext(spr_mouse_scared,0,x-45,y-125,1.8,1.8,0,c_white,1)
}
if is_stun{
	draw_sprite_ext(stun_sprite,sprite_get_number(stun_sprite)-(floor(stun_timer/5) mod sprite_get_number(stun_sprite)),x-20,y-150,1.8,1.8,0,c_white,1)
}
if(climb_stage==1){
	y = climb_base_y
}