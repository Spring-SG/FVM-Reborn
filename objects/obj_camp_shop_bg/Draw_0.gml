// 绘制事件
draw_set_alpha(0.5);
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
draw_self()

// 绘制玩家金币数量
draw_sprite_ext(spr_camp_shop_coin_display,0,x+240,y-290,1.8,1.8,0,c_white,1)
draw_sprite_ext(spr_camp_shop_coin_display,0,x+570,y-290,1.8,1.8,0,c_white,1)
draw_sprite_ext(spr_craft_material,13,x+130,y-290,0.8,0.8,0,c_white,1)
draw_sprite_ext(spr_craft_material,14,x+460,y-290,0.8,0.8,0,c_white,1)
draw_set_font(font_yuan); 
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text_transformed(x + 170, y - 290, string(get_material_amount("less_camp_coin")),1.2,1.2,0);
draw_text_transformed(x + 500, y - 290, string(get_material_amount("camp_coin")),1.2,1.2,0);
//绘制页码
draw_set_color(c_black);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_sprite_ext(spr_camp_shop_page_bg,0,x,y+428,1.8,1.8,0,c_white,1)
draw_text(x, y + 428, string(current_page)+"/"+string(current_max_page));

//绘制商品网格
for(var i = 0 ; i< 4; i++){
	for(var j = 0; j < 3; j++){
		draw_sprite_ext(spr_camp_shop_goods_bg,0,x-590+380*i,y-130+190*j,1.8,1.8,0,c_white,1)
	}
}

//按类型绘制图标

for(var i = 0 ; i< 3; i++){
	for(var j = 0; j < 4; j++){
		//绘制卡片类型商品
		if shop_button_select == 1{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*12) != undefined{
				//根据商品id获取卡片信息
				var card_data = deck_get_card_data(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].unlock_item_id,global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].target_shape)
				draw_sprite_ext(spr_slot, 0, x-590+380*j-105,y-130+190*i, 0.33, 0.33, 0, c_white, 1);
				draw_sprite_ext(card_data[? "sprite"],0,x-590+380*j-105,y-130+190*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				draw_set_color(c_black);
				draw_set_font(font_number);
				draw_text_ext_transformed(x-590+380*j-105-12, y-130+190*i+44, string(card_data[? "cost"]),25,1800,1,1,0);
				draw_sprite_ext(spr_flame, 0, x-590+380*j-105-24, y-130+190*i+43, 0.3, 0.3, 0, c_white, 1);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查卡片是否已解锁
		            var is_unlocked = false;
		            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
		                if (global.save_data.unlocked_cards[k].id == global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].unlock_item_id) {
		                    if get_card_info_simple(global.save_data.unlocked_cards[k].id).shape >= global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].target_shape{
			                    is_unlocked = true;
			                    break;
							}
		                }
		            }
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-590+380*j-188,y-130+190*i-86,x-590+380*j+188,y-130+190*i+86,false)
					draw_set_alpha(1)
					//draw_sprite_ext(spr_camp_shop_sold_out, 0, x-590+380*j,y-130+190*i, 1.8, 1.8, 0, c_white, 1);
					//instance_create_depth(x-590+380*j,y-130+190*i,depth-2,obj_sold_out_icon)
				}
			}
		}
	}
}
