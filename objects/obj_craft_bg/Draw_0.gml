panel_anim_step(id)
if (!instance_exists(id)) { exit }
draw_set_alpha(0.5 * ui_anim_alpha(id));
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
// 基底（外框 + 面板底色）：固定不动、不参与滑动，所以画在 surface 之前（在遮罩之上、三层之下）
draw_sprite_ext(spr_craft_bg_base, 0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha * ui_anim_alpha(id))
panel_anim_begin(id)
// 背景拆成三层（外框在基底里，收尾时另外画，不参与滑动）
draw_sprite_ext(spr_craft_bg_left,  0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)
draw_sprite_ext(spr_craft_bg_right, 0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)
draw_sprite_ext(spr_craft_bg_bar,   0, x, y, image_xscale, image_yscale, 0, c_white, image_alpha)

draw_sprite_ext(spr_craft_gold_require_bg,0,x-45,y+300,1.8,1.8,0,c_white,1)

draw_set_font(font_number)
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
    draw_sprite_ext(spr_package_slot_bg, 1, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
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
		draw_sprite_ext(spr_craft_material, material_info.icon, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_white)
		draw_set_font(font_number)
		if get_material_amount(material_id) < 10000{
			draw_text(x-752+i*84+40,y + 454+42,string(get_material_amount(material_id)))
		}
		else{
			draw_text(x-752+i*84+40,y + 454+42,string(floor(get_material_amount(material_id)/10000))+"w")
		}
		
	}
	if (!surface_exists(card_surface)){ card_surface = surface_create(600,815) }   // 保证配对，别 set 到不存在的 surface
	surface_set_target(card_surface)
	//绘制右侧栏位
	for(var i = 0 ; i < 7 ; i++){
        for(var j = 0 ; j < 20 ; j++){
            draw_sprite_ext(spr_package_slot_bg, 0, 42+i*84, 48+96 * j-y_offset, 0.9, 0.9, 0, c_white, 1)
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
		var card_x = 42 + card_col*84
		var card_y = 48+96 * card_row - y_offset

		if (card_slot_data != noone) {
			draw_sprite_ext(spr_slot,0,card_x,card_y-3,0.25,0.25,0,c_white,1)
			draw_sprite_ext(card_slot_data[? "sprite"],0,card_x,card_y+15,0.7,0.7,0,c_white,1)
			draw_set_color(c_black);
			draw_set_halign(fa_center);
			draw_set_valign(fa_bottom);
			draw_set_font(font_pixel)
			draw_text(card_x,card_y+37,card_slot_data[? "cost"])
			if card_data.max_level > 0{
				draw_sprite_ext(spr_star_slot,  card_data.max_level - 1,  card_x-25,  card_y-35, 0.7, 0.7, 0, c_white, 1);
			}
		}
		
		// 检查鼠标是否悬停在卡片上
        var spr_width = 84;
        var spr_height = 96;
		
		var hover_card_x = x + 196 + card_col*84
		var hover_card_y = y - 321 + 96 * card_row - y_offset
		
		if mouse_y > y-321-48 && mouse_y < y + 450{
                
	        if (point_in_rectangle(mouse_x, mouse_y, 
	                                hover_card_x - spr_width/2, hover_card_y - spr_height/2,
	                                hover_card_x + spr_width/2, hover_card_y + spr_height/2)) {
	            hover_card_index = card_index;
	        }
		}
		card_index++
	}
	surface_reset_target()
	draw_surface(card_surface,x+196-42,y-321-48)
	
	//绘制悬停提示
	if (hover_card_index != -1) {
        
		draw_set_font(font_yuan);
			tooltip_set(mouse_x - 15, mouse_y - 15, "点击将卡片放入强化槽", -1);
			
            
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
			draw_sprite_ext(spr_star_slot,  card_data.max_level - 1,  card_x-25,  card_y-35, 0.7, 0.7, 0, c_white, 1);
		}
		//绘制强化需要的材料
		if card_data.max_level <= 15{
			var spices_list = [0,0,0]
			var clover_list = [0,0,0]
			var craft_rule = get_card_craft_rule(string(card_data.max_level+1))
			draw_set_font(font_number)
			draw_set_colour(c_yellow)
			draw_set_valign(fa_middle)
			draw_set_halign(fa_left)
			draw_text(x-160,y+300,string(craft_rule.gold_amount))
			draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.spices_require).icon, x-455, y-20, 0.9, 0.9, 0, c_white, 1)
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
			draw_set_font(font_yuan)
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
				draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.clover_require).icon, x-155, y-20, 0.9, 0.9, 0, c_white, 1)
				draw_set_halign(fa_center)
				draw_set_colour(c_black)
				draw_set_font(font_number)
				draw_text(x-155,y+35,string(display_clover_amount)+"/"+string(craft_rule.clover_amount))
				draw_set_font(font_yuan)
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
	draw_sprite_ext(spr_package_gem_bg, 0, x-305, y+110, 0.9, 0.9, 0, c_white, 1)
	draw_sprite_ext(spr_craft_material_bg,0,x-305,y-40,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,3,x-305,y+110,1.8,1.8,0,c_white,1)
	draw_sprite_ext(spr_craft_slot_text,4,x-305,y-40,1.8,1.8,0,c_white,1)
	//绘制宝石强化材料
	for(var i = 0 ; i < array_length(gem_material_id_list) ; i++){
		var material_id = gem_material_id_list[i]
		var material_info = get_material_info(material_id)
		var material_amount = get_material_amount(material_id)
		draw_sprite_ext(spr_craft_material, material_info.icon, x-752+i*84, y + 454, 0.9, 0.9, 0, c_white, 1)
		draw_set_halign(fa_right);
		draw_set_valign(fa_bottom);
		draw_set_colour(c_white)
		draw_set_font(font_number)
		if get_material_amount(material_id) < 10000{
			draw_text(x-752+i*84+40,y + 454+42,string(get_material_amount(material_id)))
		}
		else{
			draw_text(x-752+i*84+40,y + 454+42,string(floor(get_material_amount(material_id)/10000))+"w")
		}
	}
	//绘制右侧栏位
	for(var i = 0 ; i < 7 ; i++){
        for(var j = 0 ; j < 9 ; j++){
            draw_sprite_ext(spr_package_slot_bg, 1, x+196+i*84, y - 324 + 88 * j, 0.9, 0.9, 0, c_white, 1)
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
                draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 0.7, 0.7, 0, c_white, 1);
                
				if get_gem_max_level(weapon_id) > 0{
					draw_sprite_ext(spr_star_slot, get_gem_max_level(weapon_id)-1, weapon_x-28, weapon_y-30, 0.7, 0.7, 0, c_white, 1)
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
			draw_set_font(font_yuan)
            var tooltip_text = weapon_data.name + "\n点击将宝石放入强化槽";
            	draw_set_font(font_yuan);
            	tooltip_set(mouse_x - 15, mouse_y - 15, tooltip_text, -1);
			
            
        }
    }
	//绘制正在强化的宝石
	if current_uprade_target_id != ""{
		var weapon_x = x - 305
        var weapon_y = y + 110
		var weapon_id = current_uprade_target_id
		var weapon_data = get_gem_info(weapon_id)
                
        // 绘制宝石图标
        draw_sprite_ext(weapon_data.icon, 0, weapon_x, weapon_y, 0.85, 0.85, 0, c_white, 1);
                
		if get_gem_max_level(weapon_id) > 0{
			draw_sprite_ext(spr_star_slot, get_gem_max_level(weapon_id)-1, weapon_x-28, weapon_y-30, 0.8, 0.8, 0, c_white, 1)
		}
		//绘制强化需要的材料
		if get_gem_max_level(weapon_id) <= 14{
			var craft_rule = get_gem_craft_rule(string(get_gem_max_level(weapon_id)+1))
			draw_set_font(font_number)
			draw_set_colour(c_yellow)
			draw_set_valign(fa_middle)
			draw_set_halign(fa_left)
			draw_text(x-160,y+300,string(craft_rule.gold_amount))
			draw_sprite_ext(spr_craft_material, get_material_info(craft_rule.crystal_require).icon, x-305, y-40, 0.9, 0.9, 0, c_white, 1)
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
			draw_set_font(font_yuan)
			if use_enhanced_crystal{
				draw_set_colour(c_red)
				draw_text(x-305,y+40,"使用了高级水晶")
			}
		}
	}
}

// ── 卡片网格滚动条（与 obj_info_island_bg / GridList 用同一个精灵和同一套交互）──────
// 卡片画进 card_surface（600×815）、贴回在 (x+196-42, y-321-48)。必须在
// panel_anim_end_parts 之前画：那之后面板 surface 已贴回，再画就录不进去了。
{
    var _sb_scl = 2.2
    var _sb_w   = sprite_get_width(spr_info_island_scroll_bar)  * _sb_scl
    var _sb_h   = sprite_get_height(spr_info_island_scroll_bar) * _sb_scl
    var _sb_l   = x + 196 - 42
    var _sb_t   = y - 321 - 48
    // 精灵原点是左上角 → x 是「按钮左边缘」，补半个按钮宽让中心落在凹槽线上
    var _sb_x   = _sb_l + 600 - _sb_w + 28 + _sb_w * 0.5
    var _sb_vh  = 815                                    // 视口高 = card_surface 高度
    var _sb_max = 96 * 20 - 815                          // 与 Mouse_61 同一上限
    // 滚动平滑趋近：滚轮与点轨道只改目标值，这里每帧非线性逼近（等级 1；等级 0 直接到位）
    if (ui_anim_on(1)) {
        y_offset += (y_offset_target - y_offset) * 0.28
        if (abs(y_offset_target - y_offset) < 0.5) y_offset = y_offset_target
    } else {
        y_offset = y_offset_target
    }

    if (_sb_max > 0 && _sb_vh > _sb_h) {
        var _sb_travel = _sb_vh - _sb_h
        var _sb_y = _sb_t + clamp(y_offset / _sb_max, 0, 1) * _sb_travel
        draw_sprite_ext(spr_info_island_scroll_bar, 0, _sb_x, _sb_y, _sb_scl, _sb_scl, 0, c_white, 1)
        if (mouse_check_button_pressed(mb_left)) {
            if (point_in_rectangle(mouse_x, mouse_y, _sb_x, _sb_y, _sb_x + _sb_w, _sb_y + _sb_h)) {
                sb_dragging = true
                sb_drag_y = mouse_y
                sb_drag_offset = y_offset
            } else if (point_in_rectangle(mouse_x, mouse_y, _sb_x, _sb_t, _sb_x + _sb_w, _sb_t + _sb_vh)) {
                y_offset_target = clamp((mouse_y - _sb_t - _sb_h * 0.5) / _sb_travel * _sb_max, 0, _sb_max)
            }
        }
        if (sb_dragging && mouse_check_button(mb_left)) {
            y_offset = clamp(sb_drag_offset + (mouse_y - sb_drag_y) * (_sb_max / _sb_travel), 0, _sb_max)
            y_offset_target = y_offset
        }
        if (mouse_check_button_released(mb_left)) sb_dragging = false
    }
}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw();
panel_anim_end_parts(id, craft_parts, 260)
