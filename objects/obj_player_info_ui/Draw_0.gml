if not global.menu_screen{
	exit
}
draw_self()

// 绘制事件
if (!surface_exists(avatar_surface)) {
    // 创建表面用于绘制圆形头像
    avatar_surface = surface_create(mask_size, mask_size);
}

if (surface_exists(avatar_surface)) {
    // 设置表面为目标
    surface_set_target(avatar_surface);
    
    // 清除为完全透明
    draw_clear_alpha(c_black, 0);
    
    // 绘制头像
    draw_sprite(spr_player_character_icon, 0, x-40, y+40);
    
    // 设置混合模式为擦除模式
    gpu_set_blendmode(bm_subtract);
    
    // 绘制圆形遮罩的反向部分（擦除圆形外的部分）
    draw_set_color(c_white);
    draw_rectangle(0, 0, mask_size, mask_size, false);
    draw_set_color(c_black);
    draw_circle(mask_size/2, mask_size/2, mask_size/2, false);
    
    // 重置混合模式
    gpu_set_blendmode(bm_normal);
    
    // 重置绘制目标
    surface_reset_target();
    
    // 绘制到屏幕
    draw_surface(avatar_surface, x+29, y+19);
}
//shader_set(avatar_shader);
//shader_set_uniform_f(u_center, 0.5, 0.5); // 圆心在纹理中心
//shader_set_uniform_f(u_radius, 0.5);      // 半径为0.5（纹理坐标空间）

//// 绘制头像
//draw_sprite(spr_player_character_icon, 0, x+90, y+70);

//// 重置着色器
//shader_reset();

//draw_sprite(spr_player_character_icon,0,x+90,y+70)
draw_set_color(c_white)
draw_sprite_ext(spr_player_levels,global.save_data.player.level - 1,x + 140 , y + 38,1.3,1.3,0,c_white,1)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text(x+290,y+38,"v1.0.0")
draw_text(x+270,y+75,global.player_name)
var hour = floor(global.total_time / 216000)
var minute = floor(global.total_time / 3600 - hour * 60)
draw_text(x+260,y+115,string(hour)+"小时"+string(minute)+"分钟")
draw_text(x+235,y+152,"不知名冒险家")
draw_set_halign(fa_left)
draw_set_valign(fa_top)