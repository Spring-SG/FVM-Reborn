draw_set_alpha(0.5);
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

draw_sprite_ext(spr_craft_gold_require_bg,0,x-45,y+300,1.8,1.8,0,c_white,1)

draw_set_font(font_yuan)
draw_set_colour(c_yellow)
draw_set_valign(fa_middle)
draw_set_halign(fa_left)
//draw_text(x-160,y+300,"300")
draw_set_halign(fa_right)
draw_text(x+758,y+473,string(global.save_data.player.gold))
draw_set_colour(c_white)
draw_set_valign(fa_top)
draw_set_halign(fa_left)
for(var i = 0 ; i < 10 ; i++){
    draw_sprite_ext(spr_package_slot_bg,1,x-752+i*84,y + 454,1.8,1.8,0,c_white,1)
}

if button_select == 0{
	//绘制卡片强化UI背景
	draw_sprite_ext(spr_craft_slot_bg,0,x-305,y+100,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_material_bg,0,x-455,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_material_bg,0,x-155,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,0,x-305,y+100,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,1,x-455,y-20,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,2,x-155,y-20,1.8,1.8,0,c_white,1)
	//绘制卡片强化材料
	for(var i = 0 ; i < array_length(card_material_id_list) ; i++){
		var material_id = card_material_id_list[i]
		var material_info = get_material_info(material_id)
		var material_amount = get_material_amount(material_id)
		draw_sprite_ext(spr_craft_material,material_info.icon,x-752+i*84,y + 454,1.8,1.8,0,c_white,1)
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_white)
		draw_set_font(font_yuan)
		if get_material_amount(material_id) < 10000{
			draw_text(x-752+i*84+40,y + 454+42,string(get_material_amount(material_id)))
		}
		else{
			draw_text(x-752+i*84+40,y + 454+42,string(floor(get_material_amount(material_id)/10000))+"万")
		}
		
	}
	//绘制右侧栏位
	for(var i = 0 ; i < 7 ; i++){
        for(var j = 0 ; j < 8 ; j++){
            draw_sprite_ext(spr_package_slot_bg,0,x+196+i*84,y - 321 + 96 * j,1.8,1.8,0,c_white,1)
        }
    }
	//绘制所有已解锁防御卡
	var card_index = 0
	hover_card_index = -1
	for(var i = 0 ; i < array_length(global.save_data.unlocked_cards);i++){
		var card_col = card_index mod 7
		var card_row = card_index div 7
		var card_data = global.save_data.unlocked_cards[i]
		var card_id = card_data.id
		var card_slot_data = deck_get_card_data(card_id,card_data.shape)
		var card_x = x+196+card_col*84
		var card_y = y - 321 + 96 * card_row
		
		draw_sprite_ext(spr_slot,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
		draw_sprite_ext(card_slot_data[? "sprite"],0,card_x,card_y+15,0.7,0.7,0,c_white,1)
		draw_set_color(c_black);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_font(font_pixel)
		draw_text(card_x,card_y+37,card_slot_data[? "cost"])
		if card_data.max_level > 0{
			draw_sprite_ext(spr_star_slot, card_data.max_level - 1, card_x-25, card_y-35,1.4,1.4,0,c_white,1);
		}
		
		// 检查鼠标是否悬停在卡片上
        var spr_width = 84;
        var spr_height = 96;
                
        if (point_in_rectangle(mouse_x, mouse_y, 
                                card_x - spr_width/2, card_y - spr_height/2,
                                card_x + spr_width/2, card_y + spr_height/2)) {
            hover_card_index = card_index;
        }
		card_index++
	}
	
	//绘制悬停提示
	if (hover_card_index != -1) {
        
		draw_set_font(font_yuan)
        // 获取鼠标位置
        var tooltip_x = mouse_x - 15;
        var tooltip_y = mouse_y - 15;
            
		// 获取提示文本
        var tooltip_text = "点击将卡片放入强化槽"
        
			
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
		draw_set_font(font_yuan)
		draw_text(tooltip_x- string_width(tooltip_text), tooltip_y, tooltip_text);
			
            
    }
	//绘制正在强化的卡片
	if current_uprade_target_id != ""{
		var card_data = get_card_info_simple(current_uprade_target_id)
		var card_id = card_data.id
		var card_slot_data = deck_get_card_data(current_uprade_target_id,card_data.shape)
		var card_x = x - 307
		var card_y = y + 103
		
		draw_sprite_ext(spr_slot,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
		draw_sprite_ext(card_slot_data[? "sprite"],0,card_x,card_y+15,0.7,0.7,0,c_white,1)
		draw_set_color(c_black);
		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_font(font_pixel)
		draw_text(card_x,card_y+37,card_slot_data[? "cost"])
		if card_data.max_level > 0{
			draw_sprite_ext(spr_star_slot, card_data.max_level - 1, card_x-25, card_y-35,1.4,1.4,0,c_white,1);
		}
		//绘制强化需要的材料
		if card_data.max_level <= 15{
			var spices_list = [0,0,0]
			var clover_list = [0,0,0]
			var craft_rule = get_card_craft_rule(string(card_data.max_level+1))
			draw_set_font(font_yuan)
			draw_set_colour(c_yellow)
			draw_set_valign(fa_middle)
			draw_set_halign(fa_left)
			draw_text(x-160,y+300,string(craft_rule.gold_amount))
			draw_sprite_ext(spr_craft_material,get_material_info(craft_rule.spices_require).icon,x-455,y-20,1.8,1.8,0,c_white,1)
			draw_set_halign(fa_center)
			draw_set_colour(c_black)
			//如果低级材料不足，尝试获取高级材料
			var display_spices_amount = 0
			var use_enhanced_spices = false
			if get_material_amount(craft_rule.spices_require) < craft_rule.spices_amount{
				for(var i = array_get_index(spices_use_order,craft_rule.spices_require);i < array_length(spices_use_order);i++){
					display_spices_amount += get_material_amount(spices_use_order[i])
					if display_spices_amount>= craft_rule.spices_amount{
						use_enhanced_spices = true
						break
					}
				}
			}
			else{
				display_spices_amount = get_material_amount(craft_rule.spices_require)
			}
			draw_text(x-455,y+35,string(display_spices_amount)+"/"+string(craft_rule.spices_amount))
			if use_enhanced_spices{
				draw_set_colour(c_red)
				draw_text(x-455,y+60,"使用了高级香料")
			}
			if craft_rule.clover_require != "none"{
				//如果低级材料不足，尝试获取高级材料
				var display_clover_amount = 0
				var use_enhanced_clover = false
				if get_material_amount(craft_rule.clover_require) < craft_rule.clover_amount{
					for(var i = array_get_index(clover_use_order,craft_rule.clover_require);i < array_length(clover_use_order);i++){
						display_clover_amount += get_material_amount(clover_use_order[i])
						if display_clover_amount>= craft_rule.clover_amount{
							use_enhanced_clover = true
							break
						}
					}
				}
				else{
					display_clover_amount = get_material_amount(craft_rule.clover_require)
				}
				draw_sprite_ext(spr_craft_material,get_material_info(craft_rule.clover_require).icon,x-155,y-20,1.8,1.8,0,c_white,1)
				draw_set_halign(fa_center)
				draw_set_colour(c_black)
				draw_text(x-155,y+35,string(display_clover_amount)+"/"+string(craft_rule.clover_amount))
				if use_enhanced_clover{
					draw_set_colour(c_red)
					draw_text(x-155,y+60,"使用了高级四叶草")
				}
			}
		}
	}
	
	
    
}
else if button_select == 1{
	//绘制宝石强化UI背景
	draw_sprite_ext(spr_package_gem_bg,0,x-305,y+110,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_material_bg,0,x-305,y-40,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,3,x-305,y+110,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,4,x-305,y-40,1.8,1.8,0,c_white,1)
	//绘制宝石强化材料
	for(var i = 0 ; i < array_length(gem_material_id_list) ; i++){
		var material_id = gem_material_id_list[i]
		var material_info = get_material_info(material_id)
		var material_amount = get_material_amount(material_id)
		draw_sprite_ext(spr_craft_material,material_info.icon,x-752+i*84,y + 454,1.8,1.8,0,c_white,1)
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_white)
		draw_set_font(font_yuan)
		if get_material_amount(material_id) < 10000{
			draw_text(x-752+i*84+40,y + 454+42,string(get_material_amount(material_id)))
		}
		else{
			draw_text(x-752+i*84+40,y + 454+42,string(floor(get_material_amount(material_id)/10000))+"万")
		}
	}
	//绘制右侧栏位
	for(var i = 0 ; i < 7 ; i++){
        for(var j = 0 ; j < 9 ; j++){
            draw_sprite_ext(spr_package_slot_bg,1,x+196+i*84,y - 324 + 88 * j,1.8,1.8,0,c_white,1)
        }
    }
	//绘制所有宝石
	var gem_index = 0
	hover_gem_index = -1
	
	for(var i = 0; i < array_length(global.save_data.unlocked_gems); i++) {
        var weapon_id = global.save_data.unlocked_gems[i].id;
        var weapon_data = get_gem_info(weapon_id)
        
        if (!is_undefined(weapon_data)) {
            // 计算宝石位置
            var row = gem_index div 7
            var col = gem_index mod 7
            
            if (row < 10) {
                var weapon_x = x + 196 + col * 84;
                var weapon_y = y - 324 + row * 88;
                
                // 绘制宝石图标
                draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 1.4, 1.4, 0, c_white, 1);
                
				if get_gem_max_level(weapon_id) > 0{
					draw_sprite_ext(spr_star_slot,get_gem_max_level(weapon_id)-1,weapon_x-28,weapon_y-30,1.4,1.4,0,c_white,1)
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
    if (hover_gem_index != -1) {
        var weapon_id = global.save_data.unlocked_gems[hover_gem_index].id;
        var weapon_data = global.gems_pool[? weapon_id];
        
        if (!is_undefined(weapon_data)) {
            // 获取鼠标位置
            var tooltip_x = mouse_x - 15;
            var tooltip_y = mouse_y - 15;
            
			// 获取提示文本
            
            var tooltip_text = ""
            var is_equipped = is_weapon_equipped(weapon_id);
            
            var slot = get_weapon_slot(weapon_id);
            tooltip_text = "点击将宝石放入强化槽"
            
			
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
	//绘制正在强化的宝石
	if current_uprade_target_id != ""{
		var weapon_x = x - 305
        var weapon_y = y + 110
		var weapon_id = current_uprade_target_id
		var weapon_data = get_gem_info(weapon_id)
                
        // 绘制宝石图标
        draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 1.7, 1.7, 0, c_white, 1);
                
		if get_gem_max_level(weapon_id) > 0{
			draw_sprite_ext(spr_star_slot,get_gem_max_level(weapon_id)-1,weapon_x-28,weapon_y-30,1.6,1.6,0,c_white,1)
		}
		//绘制强化需要的材料
		if get_gem_max_level(weapon_id) <= 14{
			var craft_rule = get_gem_craft_rule(string(get_gem_max_level(weapon_id)+1))
			draw_set_font(font_yuan)
			draw_set_colour(c_yellow)
			draw_set_valign(fa_middle)
			draw_set_halign(fa_left)
			draw_text(x-160,y+300,string(craft_rule.gold_amount))
			draw_sprite_ext(spr_craft_material,get_material_info(craft_rule.crystal_require).icon,x-305,y-40,1.8,1.8,0,c_white,1)
			draw_set_halign(fa_center)
			draw_set_colour(c_black)
			//如果低级材料不足，尝试获取高级材料
			var display_crystal_amount = 0
			var use_enhanced_crystal = false
			if get_material_amount(craft_rule.crystal_require) < craft_rule.crystal_amount{
				for(var i = array_get_index(crystal_use_order,craft_rule.crystal_require);i < array_length(crystal_use_order);i++){
					display_crystal_amount += get_material_amount(crystal_use_order[i])
					if display_crystal_amount>= craft_rule.crystal_amount{
						use_enhanced_crystal = true
						break
					}
				}
			}
			else{
				display_crystal_amount = get_material_amount(craft_rule.crystal_require)
			}
			draw_text(x-305,y+15,string(display_crystal_amount)+"/"+string(craft_rule.crystal_amount))
			if use_enhanced_crystal{
				draw_set_colour(c_red)
				draw_text(x-305,y+40,"使用了高级水晶")
			}
		}
	}
}