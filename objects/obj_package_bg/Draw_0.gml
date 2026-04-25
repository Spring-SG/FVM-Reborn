// 绘制事件
draw_set_alpha(0.5);
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

// 绘制背包格子背景
draw_sprite_ext(spr_package_bg_2,0,530,room_height/2,1.8,1.8,0,c_white,1)

// 绘制玩家金币数量
draw_set_font(font_number); 
draw_set_color(c_yellow);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(x - 180, y + 406, string(global.save_data.player.gold));

draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_bottom);
draw_set_font(font_yuan)
if info_button_select == 1{
	//绘制武器栏位文字
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(x - 1220, y - 380, "主武器");
	draw_text(x - 1220, y -120, "副武器");
	draw_text(x - 1220, y + 140, "超级武器");
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_set_font(font_yuan)
	//绘制武器栏位
	for(var i = 0;i < 3; i++){
		draw_sprite_ext(spr_package_weapon_bg,0,x-1180,y-320+260*i,2,2,0,c_white,1)
		for(var j = 0; j < 3 ; j++){
			draw_sprite_ext(spr_package_gem_bg,0,x-1180+200*j,y-220+260*i,1.8,1.8,0,c_white,1)
		}
	}
	if global.save_data.equipped_items.main_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.main_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x-1180,y-320,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.main_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			draw_sprite_ext(gem_icon,0,x-1180+200*i,y-220,1.7,1.7,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot,get_gem_level(gem_list[i])-1,x-1205+200*i,y-246,1.6,1.6,0,c_white,1)
			}
		}
	}
	if global.save_data.equipped_items.secondary_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.secondary_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x-1180,y-60,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.secondary_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			draw_sprite_ext(gem_icon,0,x-1180+200*i,y+40,1.7,1.7,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot,get_gem_level(gem_list[i])-1,x-1205+200*i,y+14,1.6,1.6,0,c_white,1)
			}
		}
	}
	if global.save_data.equipped_items.super_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.super_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x-1180,y+200,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.super_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			draw_sprite_ext(gem_icon,0,x-1180+200*i,y+300,1.7,1.7,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot,get_gem_level(gem_list[i])-1,x-1205+200*i,y+274,1.6,1.6,0,c_white,1)
			}
		}
	}
	//draw_sprite_ext(spr_attack_gem,0,x-1180,y-220,1.5,1.5,0,c_white,1)
}
else if info_button_select == 2{
	//绘制解锁信息
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(x - 1220, y - 380, "等级"+string(global.save_data.player.level));
	draw_text(x - 1220, y - 320, "最大技能等级："+string(global.save_data.unlocked_items.max_skill_level));
	draw_text(x - 1220, y - 260, "卡槽数："+string(global.save_data.unlocked_items.max_slot));
	draw_text(x - 1220, y - 200, "铲子："+string(global.save_data.unlocked_items.shovel));
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_set_font(font_yuan)
}
if package_button_select == 1 {
    for(var i = 0 ; i < package_rows ; i++){
        for(var j = 0 ; j < package_cols ; j++){
            draw_sprite_ext(spr_package_slot_bg,0,x-354+i*84,y - 361 + 96 * j,1.8,1.8,0,c_white,1)
        }
    }
    
    // 绘制所有已注册的植物卡片
    var card_index = 0;
    hover_card_index = -1; // 重置悬停卡片索引
    
    for(var i = 0; i < ds_list_size(global.player_deck); i += 2) {
        var card_id = global.player_deck[| i];
        var deck_entry = global.player_deck[| i+1];
		var card_data_shapes = deck_entry[? "shapes"]
		var card_data = {}
		var card_shape = 0
		//view_max_shapes = ds_list_size(card_data_shapes)-1
        
        // 计算卡片位置
        var row = card_index div package_rows;
        var col = card_index mod package_rows;
        
        if (row < package_rows) {
            var card_x = x - 354 + col * 84;
            var card_y = y - 359 + row * 96;
            
            // 检查卡片是否已解锁
            var is_unlocked = false;
            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
                if (global.save_data.unlocked_cards[k].id == card_id) {
                    is_unlocked = true;
					card_shape = global.save_data.unlocked_cards[k].shape
					card_data = card_data_shapes[| card_shape]
                    break;
                }
            }
            
            // 绘制卡片
            if (is_unlocked) {
                // 已解锁的卡片正常绘制
				draw_sprite_ext(spr_slot, 0, card_x, card_y-3, 0.25, 0.25, 0, c_white, 1);
                draw_sprite_ext(card_data[? "sprite"], 0, card_x, card_y+15, 0.7, 0.7, 0, c_white, 1);
				draw_set_color(c_black);
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_font(font_pixel)
				draw_text(card_x,card_y+37,card_data[? "cost"])
				draw_set_font(font_yuan)
				var length = array_length(global.save_data.unlocked_cards)
				var info_index = 0
				for (var j = 0;j < length;j++){
					if global.save_data.unlocked_cards[j].id == card_id{
						info_index = j
						break
					}
				}
				var level = global.save_data.unlocked_cards[info_index].level
				if level > 0{
					draw_sprite_ext(spr_star_slot, level - 1, card_x-25, card_y-35,1.4,1.4,0,c_white,1);
				}
                // 检查鼠标是否悬停在卡片上
                var spr_width = 84;
                var spr_height = 96;
                
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      card_x - spr_width/2, card_y - spr_height/2,
                                      card_x + spr_width/2, card_y + spr_height/2)) {
                    hover_card_index = card_index;
                }
            } else {
                // 未解锁的卡片使用灰色滤镜
				draw_sprite_ext(spr_slot, 0, card_x, card_y-3, 0.25, 0.25, 0, c_gray, 1);
				card_data = card_data_shapes[| card_shape]
                draw_sprite_ext(card_data[? "sprite"], 0, card_x, card_y+15, 0.7, 0.7, 0, c_gray, 1);
            }
            
            card_index++;
        }
    }
    
    // 绘制悬停提示
    if (hover_card_index != -1) {
        // 获取鼠标位置
        var tooltip_x = mouse_x + 15;
        var tooltip_y = mouse_y + 15;
		
		var tooltip_text = "左键点击调节卡片\n右键点击查看情报"
        
        // 绘制提示背景
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(tooltip_x - 5, tooltip_y - 5, 
                      tooltip_x + string_width(tooltip_text)+5, tooltip_y + string_height(tooltip_text)+5, false);
        
        // 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_text(tooltip_x, tooltip_y, tooltip_text);
    }
}
else if package_button_select == 2 {
    // 绘制武器背包
    for(var i = 0 ; i < package_rows ; i++){
        for(var j = 0 ; j < package_cols ; j++){
            draw_sprite_ext(spr_package_slot_bg,1,x-354+i*84,y - 368 + 88 * j,1.8,1.8,0,c_white,1)
        }
    }
    
    // 绘制所有已解锁的武器
    var weapon_index = 0;
    hover_weapon_index = -1; // 重置悬停武器索引
    
    for(var i = 0; i < array_length(global.save_data.unlocked_weapons); i++) {
        var weapon_id = global.save_data.unlocked_weapons[i].id;
        var weapon_data = global.weapon_pool[? weapon_id];
        
        if (!is_undefined(weapon_data)) {
            // 计算武器位置
            var row = weapon_index div package_rows;
            var col = weapon_index mod package_rows;
			
			gem_start_line = weapon_index div package_rows;
            
            if (row < package_rows) {
                var weapon_x = x - 354 + col * 84;
                var weapon_y = y - 368 + row * 88;
                
                // 检查武器是否已装备
                var is_equipped = is_weapon_equipped(weapon_id);
                
                // 绘制武器图标
                if (is_equipped) {
                    // 已装备的武器，用高亮边框或颜色显示
                    draw_sprite_ext(spr_package_slot_bg, 1, weapon_x, weapon_y, 1.8, 1.8, 0, c_yellow, 1);
                    draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 1, 1, 0, c_white, 1);
                } else {
                    draw_sprite_ext(spr_package_slot_bg, 1, weapon_x, weapon_y, 1.8, 1.8, 0, c_white, 1);
                    draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 1, 1, 0, c_white, 1);
                }
                
                // 检查鼠标是否悬停在武器上
                var spr_width = 84;
                var spr_height = 88;
                
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      weapon_x - spr_width/2, weapon_y - spr_height/2,
                                      weapon_x + spr_width/2, weapon_y + spr_height/2)) {
                    hover_weapon_index = i;
                }
                
                weapon_index++;
            }
        }
    }
	
	//绘制已解锁的宝石图标
	var gem_index = 0
	hover_gem_index = -1
	
	for(var i = 0; i < array_length(global.save_data.unlocked_gems); i++) {
        var weapon_id = global.save_data.unlocked_gems[i].id;
        var weapon_data = get_gem_info(weapon_id)
        
        if (!is_undefined(weapon_data)) {
            // 计算宝石位置
            var row = (gem_index div package_rows) + gem_start_line + 1;
            var col = gem_index mod package_rows;
            
            if (row < package_rows) {
                var weapon_x = x - 354 + col * 84;
                var weapon_y = y - 368 + row * 88;
                
                // 检查宝石是否已装备
                var is_equipped = (get_gem_index(weapon_id) != -1)
                
                // 绘制宝石图标
                if (is_equipped) {
                    // 已装备的宝石，用高亮边框或颜色显示
                    draw_sprite_ext(spr_package_slot_bg, 1, weapon_x, weapon_y, 1.8, 1.8, 0, c_yellow, 1);
                    draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 1.4, 1.4, 0, c_white, 1);
                } else {
                    draw_sprite_ext(spr_package_slot_bg, 1, weapon_x, weapon_y, 1.8, 1.8, 0, c_white, 1);
                    draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 1.4, 1.4, 0, c_white, 1);
                }
				if get_gem_level(weapon_id) > 0{
					draw_sprite_ext(spr_star_slot,get_gem_level(weapon_id)-1,weapon_x-28,weapon_y-30,1.4,1.4,0,c_white,1)
				}
                
                // 检查鼠标是否悬停在宝石上
                var spr_width = 84;
                var spr_height = 88;
                
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      weapon_x - spr_width/2, weapon_y - spr_height/2,
                                      weapon_x + spr_width/2, weapon_y + spr_height/2)) {
                    hover_gem_index = i;
                }
                
                gem_index++;
            }
        }
    }
    
    // 绘制悬停提示
    if (hover_weapon_index != -1) {
        var weapon_id = global.save_data.unlocked_weapons[hover_weapon_index].id;
        var weapon_data = global.weapon_pool[? weapon_id];
        
        if (!is_undefined(weapon_data)) {
            // 获取鼠标位置
            var tooltip_x = mouse_x - 15;
            var tooltip_y = mouse_y - 15;
            
			// 获取提示文本
            
            var tooltip_text = ""
            var is_equipped = is_weapon_equipped(weapon_id);
            if (is_equipped) {
                var slot = get_weapon_slot(weapon_id);
                tooltip_text = weapon_data.description + "\n已装备\n左键点击卸下"
            } else {
                tooltip_text = weapon_data.description + "\n左键点击装备"
            }
			
            // 绘制提示背景
            draw_set_color(c_black);
            draw_set_alpha(0.7);
            draw_rectangle(tooltip_x - string_width(tooltip_text) - 5, tooltip_y - 5, 
                          tooltip_x +5, tooltip_y + string_height(tooltip_text)+5, false);
			//绘制提示文本
			draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_alpha(1);
            draw_set_color(c_white);
			draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
			
            
        }
    }
    if (hover_gem_index != -1) {
        var weapon_id = global.save_data.unlocked_gems[hover_gem_index].id;
        var weapon_data = get_gem_info(weapon_id)
        
        if (!is_undefined(weapon_data)) {
            // 获取鼠标位置
            var tooltip_x = mouse_x - 15;
            var tooltip_y = mouse_y - 15;
            
			// 获取提示文本
            
            var tooltip_text = ""
            var is_equipped = (get_gem_index(weapon_id) != -1)
            if (is_equipped) {
                //var slot = get_weapon_slot(weapon_id);
                tooltip_text = weapon_data.description + "\n左键点击卸下\n右键点击编辑"
            } else {
                tooltip_text = weapon_data.description + "\n左键点击镶嵌\n右键点击编辑"
            }
			
            // 绘制提示背景
            draw_set_color(c_black);
            draw_set_alpha(0.7);
            draw_rectangle(tooltip_x - string_width(tooltip_text)- 5, tooltip_y - 5, 
                          tooltip_x +5, tooltip_y + string_height(tooltip_text)+5, false);
			//绘制提示文本
			draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_alpha(1);
            draw_set_color(c_white);
			draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
			
            
        }
    }
	

}
else if package_button_select == 3{
	// 绘制道具背包
    for(var i = 0 ; i < package_rows ; i++){
        for(var j = 0 ; j < package_cols ; j++){
            draw_sprite_ext(spr_package_slot_bg,1,x-354+i*84,y - 368 + 88 * j,1.8,1.8,0,c_white,1)
        }
    }
	// 绘制所有道具
    var material_index = 0;
    hover_material_index = -1; // 重置悬停道具索引
	var material_list = ds_map_keys_to_array(global.material_pool)
    
    for(var i = 0; i < array_length(material_list); i++) {
        var material_id = material_list[i]
        var material_data = get_material_info(material_id)
        
        if (!is_undefined(material_data)) {
            // 计算道具位置
            var row = material_data.pos_y;
            var col = material_data.pos_x;
            
            if (row < package_rows) {
                var material_x = x - 354 + col * 84;
                var material_y = y - 368 + row * 88;
                               
                //draw_sprite_ext(spr_package_slot_bg, 1, weapon_x, weapon_y, 1.8, 1.8, 0, c_white, 1);
                draw_sprite_ext(spr_craft_material,material_data.icon, material_x, material_y, 1.8, 1.8, 0, c_white, 1);
				draw_set_halign(fa_right);
				draw_set_valign(fa_bottom);
				draw_set_colour(c_white)
				draw_set_font(font_number)
				if get_material_amount(material_id) < 10000{
					draw_text(material_x+40,material_y+42,string(get_material_amount(material_id)))
				}
				else{
					draw_text(material_x+40,material_y+42,string(floor(get_material_amount(material_id)/10000))+"w")
				}
                
                // 检查鼠标是否悬停在道具上
                var spr_width = 84;
                var spr_height = 88;
                
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      material_x - spr_width/2, material_y - spr_height/2,
                                      material_x + spr_width/2, material_y + spr_height/2)) {
                    hover_material_index = i;
                }
                
                material_index++;
            }
        }
    }
	// 绘制悬停提示
    if (hover_material_index != -1) {
		var material_list = ds_map_keys_to_array(global.material_pool)
        var material_id = material_list[hover_material_index]
        var material_data = get_material_info(material_id)
        
        if (!is_undefined(material_data)) {
            // 获取鼠标位置
            var tooltip_x = mouse_x - 15;
            var tooltip_y = mouse_y - 15;
            
			// 获取提示文本
            
            var tooltip_text = ""
            
			tooltip_text = material_data.description + "\n数量："+string(get_material_amount(material_id))
            
			
            // 绘制提示背景
			draw_set_font(font_yuan)
            draw_set_color(c_black);
            draw_set_alpha(0.7);
            draw_rectangle(tooltip_x - string_width(tooltip_text) - 5, tooltip_y - 5, 
                          tooltip_x +5, tooltip_y + string_height(tooltip_text)+5, false);
			//绘制提示文本
			draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_alpha(1);
            draw_set_color(c_white);
			draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
			
            
        }
    }
}

// 重置绘制设置
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);