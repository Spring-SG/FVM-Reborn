// 绘制事件
draw_set_alpha(0.5);
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

// 绘制背包格子背景
draw_sprite_ext(spr_info_island_bg_1,0,530,room_height/2,1.8,1.8,0,c_white,1)

// 绘制玩家金币数量
draw_set_font(font_yuan); // 假设有一个字体font_main
draw_set_color(c_yellow);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_font(font_yuan)

if info_button_select == 1 {
	if surface_exists(info_surface){
		surface_set_target(info_surface)
		draw_clear_alpha(c_black,0)
    for(var i = 0 ; i < info_rows ; i++){
        for(var j = 0 ; j < info_cols ; j++){
			if j + i * info_cols == select_card_index{
				draw_sprite_ext(spr_info_island_info_bg,1,x-1154+j*128*1.5,y - 435 + 142*1.5 * i-y_offset,1.5,1.5,0,c_white,1)
			}
			else{
				draw_sprite_ext(spr_info_island_info_bg,0,x-1154+j*128*1.5,y - 435 + 142*1.5 * i-y_offset,1.5,1.5,0,c_white,1)
			}
        }
    }
    
    // 绘制所有已注册的植物卡片
    var card_index = 0;
    hover_card_index = -1; // 重置悬停卡片索引
    
    for(var i = 0; i < ds_list_size(global.player_deck); i += 2) {
        var card_id = global.player_deck[| i];
        var deck_entry = global.player_deck[| i+1];
		var card_data_shapes = deck_entry[? "shapes"]
		var card_data = card_data_shapes[| 0]
		var info = get_plant_shape_data(card_id,0)
		var card_shape = 0
        
        // 计算卡片位置
        var row = card_index div info_cols;
        var col = card_index mod info_cols;
        
        if (row < info_rows) {
            var card_x = x - 1154 + col * 128*1.5;
            var card_y = y - 435 + row * 142*1.5-y_offset;
			var slot_bg_spr = variable_struct_exists(global.night_plants, card_id) ? spr_slot_night : spr_slot;
            
            // 绘制卡片
				draw_sprite_ext(slot_bg_spr, 0, card_x, card_y-3, 0.30, 0.30, 0, c_white, 1);
                draw_sprite_ext(card_data[? "sprite"], 0, card_x, card_y+15, 0.8, 0.8, 0, c_white, 1);
				draw_set_color(c_white);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				draw_set_font(font_yuan)
				draw_text(card_x,card_y+87,info[? "name"])
				draw_set_font(font_yuan)
                // 检查鼠标是否悬停在卡片上
                var spr_width = 128*1.5;
                var spr_height = 142*1.5;
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      card_x - spr_width/2, card_y + 45,
                                      card_x + spr_width/2, card_y + 45+spr_height)) 
				&& mouse_y >= y - 375 && mouse_y <= y - 375 + surface_height {
                    hover_card_index = card_index;
                }
				if card_index == hover_card_index{
					draw_set_alpha(1)
					draw_sprite_ext(spr_info_island_select_box,0,card_x,card_y,2,2,0,c_white,0.5)
				}
                        
            card_index++;
        }
    }
	
	surface_reset_target()
	}
	draw_surface(info_surface,x-1380,y-368)
    // 绘制悬停提示
    if (hover_card_index != -1) {
        // 获取鼠标位置
        var tooltip_x = mouse_x + 15;
        var tooltip_y = mouse_y - 15;
		var row = hover_card_index div info_cols;
        var col = hover_card_index mod info_cols;
        
        if (row < info_rows) {
            var card_x = x - 1154 + col * 128*1.5;
            var card_y = y - 265 + row * 142*1.5-y_offset;
			//draw_sprite_ext(spr_info_island_select_box,0,card_x,card_y,2,2,0,c_white,0.5)
		}
		
        
        // 绘制提示背景
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(tooltip_x - 5, tooltip_y - 5, 
                      tooltip_x + 150, tooltip_y + 30, false);
        
        // 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(tooltip_x, tooltip_y, "点击查看情报");
    }
	if select_card_index != -1{
		//绘制右侧信息栏
		var card_id = global.player_deck[| select_card_index*2];
	    var deck_entry = global.player_deck[| select_card_index*2+1];
		var card_data_shapes = deck_entry[? "shapes"]
		
		
		var card_shape = view_card_shape
	
		var max_shape = ds_list_size(card_data_shapes)-1
		var current_view_shape = 0
		
		if view_card_shape >= max_shape{
			current_view_shape = max_shape
		}
		else{
			current_view_shape = view_card_shape
		}
		var card_data = card_data_shapes[| current_view_shape]
		var info = get_plant_data_with_skill(card_id, current_view_shape,view_card_level,view_card_skill);
		var name = get_plant_shape_data(card_id,current_view_shape)[? "name"]
		var info_text = global.info_island[? card_id]
		
		//绘制文本
		draw_set_font(font_hei)
		draw_sprite_ext(card_data[? "sprite"], 0, x-320, y-210, 1.5, 1.5, 0, c_white, 1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_text(x-360,y-350,"当前查看数值：星级："+string(view_card_level)+"，转职："+string(current_view_shape)+"，技能："+string(view_card_skill))
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(x-320,y-190,name)
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		var sun = string(info[? "flame_produce"])
		if sun == "undefined"{
			sun = "无"
		}
		draw_text_ext_transformed(x-200,y-290,"攻击力："+string(info[? "atk"])+"\n"+"生命值："+string(info[? "hp"])+"\n"+"能量消耗："+string(info[? "cost"]),40,1920,1,1,0)
		draw_text_ext_transformed(x,y-290,"攻击间隔："+string(info[? "cycle"]/60)+"\n"+"冷却时间："+string(info[? "cooldown"]/60)+"\n"+"火苗产量："+sun,40,1920,1,1,0)
		draw_text_ext(x-390,y-100,info_text,30,300)
		draw_set_font(font_yuan)
	}
}
else if info_button_select == 2 {
	if surface_exists(info_surface){
		surface_set_target(info_surface)
		draw_clear_alpha(c_black,0)
    for(var i = 0 ; i < info_rows ; i++){
        for(var j = 0 ; j < info_cols ; j++){
			if j + i * info_cols == select_card_index{
				draw_sprite_ext(spr_info_island_info_bg,1,x-1154+j*128*1.5,y - 435 + 142*1.5 * i-y_offset,1.5,1.5,0,c_white,1)
			}
			else{
				draw_sprite_ext(spr_info_island_info_bg,0,x-1154+j*128*1.5,y - 435 + 142*1.5 * i-y_offset,1.5,1.5,0,c_white,1)
			}
        }
    }
    
    // 绘制所有已注册的敌人
    var enemy_index = 0;
    hover_card_index = -1; // 重置悬停卡片索引
    
	var enemy_id_array = global.enemy_id_list
    for(var i = 0; i < array_length(enemy_id_array); i += 1) {
        var enemy_id = enemy_id_array[i]
		var enemy_data = global.enemy_map[? enemy_id];
		var info = global.enemy_info_island[? enemy_id]
        
        // 计算敌人位置
        var row = enemy_index div info_cols;
        var col = enemy_index mod info_cols;
        
        if (row < info_rows) {
            var card_x = x - 1154 + col * 128*1.5;
            var card_y = y - 435 + row * 142*1.5-y_offset;
            
            // 绘制敌人
				
                draw_sprite_ext(enemy_data.spr, 0, card_x, card_y+65, 1, 1, 0, c_white, 1);
				draw_set_color(c_white);
				draw_set_halign(fa_center);
				draw_set_valign(fa_middle);
				draw_set_font(font_yuan)
				draw_text(card_x,card_y+87,enemy_data.name)
				draw_set_font(font_yuan)
                // 检查鼠标是否悬停在敌人上
                var spr_width = 128*1.5;
                var spr_height = 142*1.5;
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      card_x - spr_width/2, card_y + 45,
                                      card_x + spr_width/2, card_y + 45+spr_height)) 
				&& mouse_y >= y - 375 && mouse_y <= y - 375 + surface_height {
                    hover_card_index = enemy_index;
                }
				if enemy_index == hover_card_index{
					draw_set_alpha(1)
					draw_sprite_ext(spr_info_island_select_box,0,card_x,card_y,2,2,0,c_white,0.5)
				}
                        
            enemy_index++;
        }
    }
	
	surface_reset_target()
	}
	draw_surface(info_surface,x-1380,y-368)
    // 绘制悬停提示
    if (hover_card_index != -1) {
        // 获取鼠标位置
        var tooltip_x = mouse_x + 15;
        var tooltip_y = mouse_y - 15;
		var row = hover_card_index div info_cols;
        var col = hover_card_index mod info_cols;
        
        if (row < info_rows) {
            var card_x = x - 1154 + col * 128*1.5;
            var card_y = y - 265 + row * 142*1.5-y_offset;
			//draw_sprite_ext(spr_info_island_select_box,0,card_x,card_y,2,2,0,c_white,0.5)
		}
		
        
        // 绘制提示背景
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(tooltip_x - 5, tooltip_y - 5, 
                      tooltip_x + 150, tooltip_y + 30, false);
        
        // 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(tooltip_x, tooltip_y, "点击查看情报");
    }
	if select_card_index != -1{
		//绘制右侧信息栏
		var enemy_id_array = global.enemy_id_list
        var enemy_id = enemy_id_array[select_card_index]
		var enemy_data = global.enemy_map[? enemy_id];
		var info = global.enemy_info_island[? enemy_id]
		var name = enemy_data.name
		
		
		//绘制文本
		draw_set_font(font_hei)
		draw_sprite_ext(enemy_data.spr, 0, x-320, y-180, 1.5, 1.5, 0, c_white, 1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		//draw_text(x-360,y-350,"当前查看数值：星级："+string(view_card_level)+"，转职："+string(current_view_shape)+"，技能："+string(view_card_skill))
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(x-320,y-160,name)
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		var ash = "否"
		if enemy_data.ash_proof{
			ash = "是"
		}
		draw_text_ext_transformed(x-200,y-310,"攻击力："+string(enemy_data.atk)+"\n"+"生命值："+string(enemy_data.hp)+"\n"+"移动速度："+string(enemy_data.speed),40,1920,1,1,0)
		draw_text_ext_transformed(x,y-310,"攻击间隔："+string(enemy_data.cycle/60)+"\n"+"盾牌血量："+string(enemy_data.shield)+"\n"+"防爆："+ash,40,1920,1,1,0)
		draw_text_ext(x-390,y-100,info,30,300)
		draw_set_font(font_yuan)
	}
}
else if info_button_select == 3 {
	if surface_exists(info_surface){
		surface_set_target(info_surface)
		draw_clear_alpha(c_black,0)
    for(var i = 0 ; i < info_rows ; i++){
        for(var j = 0 ; j < info_cols ; j++){
			if j + i * info_cols == select_card_index{
				draw_sprite_ext(spr_info_island_info_bg,1,x-1154+j*128*1.5,y - 435 + 142*1.5 * i-y_offset,1.5,1.5,0,c_white,1)
			}
			else{
				draw_sprite_ext(spr_info_island_info_bg,0,x-1154+j*128*1.5,y - 435 + 142*1.5 * i-y_offset,1.5,1.5,0,c_white,1)
			}
        }
    }
    
    // 绘制所有已注册的关卡
    var enemy_index = 0;
    hover_card_index = -1; // 重置悬停卡片索引
    
	var enemy_id_array = global.level_id_list
    for(var i = 0; i < array_length(enemy_id_array); i += 1) {
        var enemy_id = enemy_id_array[i]
		var enemy_data = global.level_info_island_map[? enemy_id];
		var info = enemy_data.description
        
        // 计算敌人位置
        var row = enemy_index div info_cols;
        var col = enemy_index mod info_cols;
        
        if (row < info_rows) {
            var card_x = x - 1154 + col * 128*1.5;
            var card_y = y - 435 + row * 142*1.5-y_offset;
            
            // 绘制敌人
			if struct_exists(enemy_data,"spr_index"){
				draw_sprite_ext(enemy_data.icon, enemy_data.spr_index, card_x, card_y, 0.2, 0.2, 0, c_white, 1);
			}
			else{
				draw_sprite_ext(enemy_data.icon, enemy_index, card_x, card_y, 0.2, 0.2, 0, c_white, 1);
			}
			draw_set_color(c_white);
			draw_set_halign(fa_center);
			draw_set_valign(fa_middle);
			draw_set_font(font_yuan)
			draw_text(card_x,card_y+87,enemy_data.name)
			draw_set_font(font_yuan)
            // 检查鼠标是否悬停在敌人上
            var spr_width = 128*1.5;
            var spr_height = 142*1.5;
            if (point_in_rectangle(mouse_x, mouse_y, 
                                    card_x - spr_width/2, card_y + 45,
                                    card_x + spr_width/2, card_y + 45+spr_height)) 
			&& mouse_y >= y - 375 && mouse_y <= y - 375 + surface_height {
                hover_card_index = enemy_index;
            }
			if enemy_index == hover_card_index{
				draw_set_alpha(1)
				draw_sprite_ext(spr_info_island_select_box,0,card_x,card_y,2,2,0,c_white,0.5)
			}
                        
            enemy_index++;
        }
    }
	
	surface_reset_target()
	}
	draw_surface(info_surface,x-1380,y-368)
    // 绘制悬停提示
    if (hover_card_index != -1) {
        // 获取鼠标位置
        var tooltip_x = mouse_x + 15;
        var tooltip_y = mouse_y - 15;
		var row = hover_card_index div info_cols;
        var col = hover_card_index mod info_cols;
        
        if (row < info_rows) {
            var card_x = x - 1154 + col * 128*1.5;
            var card_y = y - 265 + row * 142*1.5-y_offset;
			//draw_sprite_ext(spr_info_island_select_box,0,card_x,card_y,2,2,0,c_white,0.5)
		}
		
        
        // 绘制提示背景
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(tooltip_x - 5, tooltip_y - 5, 
                      tooltip_x + 150, tooltip_y + 30, false);
        
        // 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(tooltip_x, tooltip_y, "点击查看情报");
    }
	if select_card_index != -1{
		//绘制右侧信息栏
		var enemy_id_array = global.level_id_list
        var enemy_id = enemy_id_array[select_card_index]
		var enemy_data = global.level_info_island_map[? enemy_id];
		var info = enemy_data.description
		var name = enemy_data.name
		
		
		//绘制文本
		draw_set_font(font_hei)
		draw_sprite_ext(enemy_data.spr, 0, x-390, y-355, 0.2, 0.2, 0, c_white, 1);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		//draw_text(x-360,y-350,"当前查看数值：星级："+string(view_card_level)+"，转职："+string(current_view_shape)+"，技能："+string(view_card_skill))
		draw_set_color(c_white);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		//draw_text(x-320,y-160,name)
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		draw_text_ext(x-390,y-100,info,30,300)
		draw_set_font(font_yuan)
	}
}


// 重置绘制设置
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);