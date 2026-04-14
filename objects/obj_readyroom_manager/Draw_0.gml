draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_set_font(font_yuan)
draw_text(190,45,global.map_name)
draw_set_color(c_black)
draw_text(565,53,global.level_data.name)
{//绘制可选择的防御卡
	surface_set_target(slot_surface)
for(var i = 0 ; i < slot_rows ; i++){
        for(var j = 0 ; j < slot_cols ; j++){
            draw_sprite_ext(spr_package_slot_bg,0,x+42+i*84,y + 48 + 96 * j- y_offset,1.8,1.8,0,c_white,1)
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
        var row = card_index div slot_rows;
        var col = card_index mod slot_rows;
        
        if (row < slot_rows) {
            var card_x = x + 42 + col * 84
            var card_y = y + 48 + row * 96 - y_offset;
            var slot_bg_spr = variable_struct_exists(global.night_plants, card_id) ? spr_slot_night : spr_slot;
			
            // 检查卡片是否已解锁
            var is_unlocked = false;
			var is_selected = false
            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
                if (global.save_data.unlocked_cards[k].id == card_id) {
                    is_unlocked = true;
					card_shape = global.save_data.unlocked_cards[k].shape
					card_data = card_data_shapes[| card_shape]
                    break;
                }
            }
			for(var s = 0;s<ds_list_size(global.selected_deck);s++){
				if global.selected_deck[| s][? "card_id"] == card_id{
					is_unlocked = false
					is_selected = true
					break
				}
			}
            
            // 绘制卡片
            if (is_unlocked) {
                // 已解锁的卡片正常绘制
				draw_sprite_ext(slot_bg_spr, 0, card_x, card_y-3, 0.25, 0.25, 0, c_white, 1);
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
				
				var hover_x = x + 803 + col * 84
				var hover_y = y + 375 + row * 96 - y_offset
                
                if (point_in_rectangle(mouse_x, mouse_y, 
                                      hover_x - spr_width/2, hover_y - spr_height/2,
                                      hover_x + spr_width/2, hover_y + spr_height/2)) 
				&& mouse_y > y+315 && mouse_y < y+755{
                    hover_card_index = card_index;
                }
            } else if (is_selected){
                // 未解锁的卡片使用灰色滤镜
				draw_set_color(c_black);
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_set_font(font_pixel)
				draw_sprite_ext(slot_bg_spr, 0, card_x, card_y-3, 0.25, 0.25, 0, c_gray, 1);
				card_data = card_data_shapes[| card_shape]
                draw_sprite_ext(card_data[? "sprite"], 0, card_x, card_y+15, 0.7, 0.7, 0, c_gray, 1);
				var info_index = 0
				var length = array_length(global.save_data.unlocked_cards)
				for (var j = 0;j < length;j++){
					if global.save_data.unlocked_cards[j].id == card_id{
						info_index = j
						break
					}
				}
				var level = global.save_data.unlocked_cards[info_index].level
				if level > 0{
					draw_sprite_ext(spr_star_slot, level - 1, card_x-25, card_y-35,1.4,1.4,0,c_gray,1);
				}
				draw_text(card_x,card_y+37,card_data[? "cost"])
            }
            
            card_index++;
        }
    }
	surface_reset_target()
}
draw_surface(slot_surface,x-25+803-42,y+ 375-48)
{// 绘制悬停提示
    if (hover_card_index != -1 && !is_submenu_open) {
		var card_id = global.player_deck[| hover_card_index*2];
        var deck_entry = global.player_deck[| hover_card_index*2+1];
		var card_data_shapes = deck_entry[? "shapes"]
		var card_data = {}
		var card_shape = 0
		var tooltip_text = "点击选中"
		//view_max_shapes = ds_list_size(card_data_shapes)-1
           
            
            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
                if (global.save_data.unlocked_cards[k].id == card_id) {
					card_shape = global.save_data.unlocked_cards[k].shape
					card_data = card_data_shapes[| card_shape]
					tooltip_text = card_data[? "description"]
                    break;
                }
            }
        // 获取鼠标位置
        var tooltip_x = mouse_x - 15;
        var tooltip_y = mouse_y - 25;
		
		
        draw_set_font(font_yuan)
        // 绘制提示背景
        draw_set_color(c_black);
        draw_set_alpha(0.7);
        draw_rectangle(tooltip_x + 5, tooltip_y - 5, 
                      tooltip_x - string_width(tooltip_text)-5, tooltip_y + string_height(tooltip_text)+5, false);
        
        // 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
        draw_set_alpha(1);
        draw_set_color(c_white);
		
        draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
    }
}	
{//绘制已选择的卡组
draw_sprite_ext(spr_ready_room_slot,0,x+1271,y+129,1.84,1.84,0,c_white,1)
for(var i = 0;i<11;i++){
	draw_sprite_ext(spr_package_slot_bg,0,x+805+i*86,y + 130,1.8,1.8,0,c_white,1)
	if i+deck_first_slot_index < global.save_data.unlocked_items.max_slot{
		draw_sprite_ext(spr_ready_room_slot_number,i+deck_first_slot_index,x+805+i*86,y + 130,1.8,1.8,0,c_white,1)
	}
	else{
		draw_sprite_ext(spr_ready_room_slot_lock,0,x+805+i*86,y + 130,1.8,1.8,0,c_white,1)
	}
	
}
hover_slot_index = -1
for(var i = deck_first_slot_index; i < deck_first_slot_index+11;i++){
	if i < ds_list_size(global.selected_deck){
	var card_id = global.selected_deck[| i][? "card_id"]
	var card_shape = global.selected_deck[| i][? "shape"]
	var card_data = global.selected_deck[| i][? "data"]
	var card_spr = card_data[? "sprite"]
	var card_cost = card_data[? "cost"]
	
	var card_x = x + 805 + (i - deck_first_slot_index) * 86;
    var card_y = y + 132
	var slot_bg_spr = variable_struct_exists(global.night_plants, card_id) ? spr_slot_night : spr_slot;
	// 已解锁的卡片正常绘制
				draw_sprite_ext(slot_bg_spr, 0, card_x, card_y-3, 0.25, 0.25, 0, c_white, 1);
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
                    hover_slot_index = i;
                }
	}
	
}
}
{//绘制装备的武器
	//绘制武器栏位文字
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_set_font(font_yuan)
	draw_text(x+88 , y + 103, "装备配置");
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_bottom);
	draw_set_font(font_yuan)
	//绘制武器栏位
	for(var i = 0;i < 3; i++){
		draw_sprite_ext(spr_package_weapon_bg,0,x+120,y+160+100*i,2,2,0,c_white,1)
		for(var j = 0; j < 3 ; j++){
			draw_sprite_ext(spr_package_gem_bg,0,x+240+120*j,y+160+100*i,1.7,1.7,0,c_white,1)
		}
	}
	if global.save_data.equipped_items.main_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.main_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x+120,y+160,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.main_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			draw_sprite_ext(gem_icon,0,x+240+120*i,y+160,1.6,1.6,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot,get_gem_level(gem_list[i])-1,x+215+120*i,y+134,1.5,1.5,0,c_white,1)
			}
		}
	}
	if global.save_data.equipped_items.secondary_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.secondary_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x+120,y+260,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.secondary_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			draw_sprite_ext(gem_icon,0,x+240+120*i,y+260,1.6,1.6,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot,get_gem_level(gem_list[i])-1,x+215+120*i,y+234,1.5,1.5,0,c_white,1)
			}
		}
	}
	if global.save_data.equipped_items.super_weapon.id != ""{
		var main_weapon_icon = get_weapon_info(global.save_data.equipped_items.super_weapon.id).icon
		draw_sprite_ext(main_weapon_icon,0,x+120,y+360,1,1,0,c_white,1)
		var gem_list = global.save_data.equipped_items.super_weapon.gems
		for(var i = 0 ; i < array_length(gem_list);i++){
			var gem_icon = get_gem_info(gem_list[i]).icon
			draw_sprite_ext(gem_icon,0,x+240+120*i,y+360,1.6,1.6,0,c_white,1)
			if get_gem_level(gem_list[i]) > 0{
				draw_sprite_ext(spr_star_slot,get_gem_level(gem_list[i])-1,x+215+120*i,y+334,1.5,1.5,0,c_white,1)
			}
		}
	}
	//draw_sprite_ext(spr_attack_gem,0,x+240,y+160,1.4,1.4,0,c_white,1)
}
{//绘制关卡信息
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_middle)
	draw_set_font(font_yuan)
	
	//绘制基本信息
	draw_text(120,450,"关卡总波数："+string(global.level_file.total_waves))
	draw_text(120,490,"精英段波次："+string(global.level_file.elite_wave))
	draw_text(120,530,"初始火苗："+string(global.level_file.starting_flame))
	draw_text(120,570,"关卡限时："+string(global.level_file.time_limit))
	draw_text(120,610,"关卡特性："+ (global.level_file.level_time_feature == "night" ? "黑夜":"白天"))
	var wave_data = global.level_file.waves
	var boss_amount = 0
	for(var i = 0 ; i < array_length(wave_data) ; i++){
		if wave_data[i].boss_wave{boss_amount++}
	}
	draw_text(120,650,"BOSS数量："+string(boss_amount))
	
	//绘制奖励
	if global.level_file.version != "1.0.0"{
		if array_get_index(global.save_data.completed_levels,global.level_data.id) == -1{
			draw_text(100,780,"关卡奖励（首通）")
			draw_text(100,820,"金币（"+string(global.level_file.rewards[1].gold)+"）")
			draw_text(100,860,"技能："+string(global.level_file.rewards[1].skill_level)+"级")
			var item_string = ""
			var item_list = global.level_file.rewards[1].items
			for(var i = 0 ; i < array_length(item_list) ; i++){
				var item_id = item_list[i].id
				var item_data = get_material_info(item_id)
				item_string += (item_data.name + "（"+string(item_list[i].amount)+"） ")
			}
			draw_text(100,900,item_string)
			draw_text(100,940,"等级："+string(global.level_file.rewards[1].player_level)+"级")
			var card_string = ""
			var card_unlock_id_list = global.level_file.rewards[1].card_unlock
			for(var i = 0 ; i < array_length(card_unlock_id_list) ; i++){
				var card_id = card_unlock_id_list[i]
				var card_data = get_plant_shape_data(card_id,0)
				card_string += (card_data[? "name"] + " ")
			}
			draw_text(100,980,"卡片解锁："+card_string)
			var weapon_string = ""
			var weapon_unlock_id_list = global.level_file.rewards[1].weapon_unlock
			for(var i = 0 ; i < array_length(weapon_unlock_id_list) ; i++){
				var weapon_id = weapon_unlock_id_list[i]
				var weapon_data = get_weapon_info(weapon_id)
				weapon_string += (weapon_data.name + " ")
			}
			draw_text(100,1020,"武器解锁："+weapon_string)
			var gem_string = ""
			var gem_unlock_id_list = global.level_file.rewards[1].gem_unlock
			for(var i = 0 ; i < array_length(gem_unlock_id_list) ; i++){
				var gem_id = gem_unlock_id_list[i]
				var gem_data = get_gem_info(gem_id)
				gem_string += (gem_data.name + " ")
			}
			draw_text(100,1060,"宝石解锁："+gem_string)
		}
		else{
			draw_text(100,780,"关卡奖励")
			draw_text(100,820,"金币（"+string(global.level_file.rewards[0].gold)+"）")
			var item_string = ""
			var item_list = global.level_file.rewards[0].items
			for(var i = 0 ; i < array_length(item_list) ; i++){
				var item_id = item_list[i].id
				var item_data = get_material_info(item_id)
				item_string += (item_data.name + "（"+string(item_list[i].amount)+"） ")
			}
			draw_text(100,860,item_string)
		}
	}
	
	//关卡地图和敌人提示
	surface_set_target(map_surface)
	draw_sprite_ext(global.level_data.level_sprite,0,x,y,0.2,0.2,0,c_white,1)
	surface_reset_target()
	draw_surface(map_surface,760,771)
	for(var i = 0;i < array_length(enemy_type_list);i++){
		if i <= 5{
			var enemy_spr = global.enemy_map[? enemy_type_list[i]].spr
			draw_sprite_ext(enemy_spr,0,1070+i*90,960,1.5,1.5,0,c_white,1)
		}
	}
	//打开关卡详情位置检测
	if(mouse_x > 785 && mouse_x < 1546 && mouse_y > 762 && mouse_y < 980) && !is_submenu_open{
		draw_set_alpha(0.5)
		draw_set_colour(c_white)
		draw_roundrect(785,762,1546,980,0)
		draw_set_alpha(1)
		var tooltip_text = "点击打开关卡详情"
		// 获取鼠标位置
	    var tooltip_x = mouse_x - 15;
	    var tooltip_y = mouse_y - 25;
		
		
	    draw_set_font(font_yuan)
	    // 绘制提示背景
	    draw_set_color(c_black);
	    draw_set_alpha(0.7);
	    draw_rectangle(tooltip_x + 5, tooltip_y - 5, 
	                    tooltip_x - string_width(tooltip_text)-5, tooltip_y + string_height(tooltip_text)+5, false);
        
	    // 绘制提示文本
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
	    draw_set_alpha(1);
	    draw_set_color(c_white);
		
	    draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
	
		draw_set_valign(fa_top)
	}
	
}
draw_set_color(c_white);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_font(font_yuan)
draw_text(1820,1080,"按ESC退出")