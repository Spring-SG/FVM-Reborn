panel_anim_step(id)
if (!instance_exists(id)) { exit }
// 绘制事件
draw_set_alpha(0.5 * ui_anim_alpha(id));
// 绘制半透明遮罩
draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);
panel_anim_begin(id)
draw_self()

// 绘制玩家金币数量
draw_set_font(font_number); 
draw_set_color(c_yellow);
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_text(x - 485, y + 447, string(global.save_data.player.gold));
//绘制页码
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(x + 387, y + 435, string(current_page)+"/"+string(current_max_page));
//绘制背景
draw_sprite_ext(spr_shop_bg_2,0,x,y+58,1.8,1.8,0,c_white,1)

//绘制商品网格
for(var i = 0 ; i< 4; i++){
	for(var j = 0; j < 4; j++){
		draw_sprite_ext(spr_shop_goods_bg,0,x-618+411*i,y-190+165*j,1.8,1.8,0,c_white,1)
	}
}

// ── 页签切换：整页淡入（旧页当帧消失，不做退场）──
// 面板自己画的商品格与标签统一吃 draw_set_alpha；子对象 obj_shop_buy_btn 是切页签时
// 销毁重建的，所以按类型逐帧写 image_alpha，不依赖数组。
if (pg_t >= 0) {
	pg_t++;
	if (pg_t > pg_frames) pg_t = -1;
}
var _pg_ease = 1;
if (pg_t >= 0) {
	var _pg_p = pg_t / pg_frames;
	_pg_ease = 1 - (1 - _pg_p) * (1 - _pg_p) * (1 - _pg_p);
}
// 入场期间不写子对象：kid-sync 会覆盖
if (pg_t >= 0 && pnl_o >= 0.999) {
	with (obj_shop_buy_btn) { image_alpha = _pg_ease }
}
// 商品格内部成对使用 draw_set_alpha(0.5)/(1)（售罄压暗），外层 alpha 会被中途复位，故这段内容
// 录进 pg_surf 后整体乘淡入值贴回。
var _pg_live = false;
if (pg_t >= 0 && pnl_o >= 0.999) {
	if (!surface_exists(pg_surf)) pg_surf = surface_create(room_width, room_height);
	if (surface_exists(pg_surf)) {
		surface_set_target(pg_surf);
		draw_clear_alpha(c_black, 0);
		_pg_live = true;
	}
}

//按类型绘制图标

for(var i = 0 ; i< 4; i++){
	for(var j = 0; j < 4; j++){
		//绘制卡片类型商品
		if shop_button_select == 1{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = deck_get_card_data(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id,0)
				draw_sprite_ext(spr_slot, 0, x-618+411*j-122,y-190+165*i, 0.33, 0.33, 0, c_white, 1);
				draw_sprite_ext(card_data[? "sprite"],0,x-618+411*j-122,y-190+165*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				draw_set_color(c_black);
				draw_set_font(font_number);
				draw_text_ext_transformed(x-618+411*j-122-12, y-190+165*i+44, string(card_data[? "cost"]),25,1800,1,1,0);
				draw_sprite_ext(spr_flame, 0, x-618+411*j-122-24, y-190+165*i+43, 0.3, 0.3, 0, c_white, 1);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查卡片是否已解锁
		            var is_unlocked = false;
		            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
		                if (global.save_data.unlocked_cards[k].id == global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id) {
		                    is_unlocked = true;
		                    break;
		                }
		            }
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
			}
		}
		//绘制装备类型商品
		else if shop_button_select == 2{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据id获取装备信息
				var goods_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				if goods_data.type == "weapon"{
					var weapon_data = get_weapon_info(goods_data.unlock_item_id)
					draw_sprite_ext(weapon_data.icon,0,x-618+411*j-122,y-210+165*i+25,1.5,1.5,0,c_white,1)
					//检查是否解锁
					var is_unlocked = is_weapon_unlocked(goods_data.unlock_item_id)
					if is_unlocked{
					
						draw_set_color(c_black)
						draw_set_alpha(0.5)
						draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
						draw_set_alpha(1)
						draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
					}
				}
				else if goods_data.type == "gem"{
					var weapon_data = get_gem_info(goods_data.unlock_item_id)
					draw_sprite_ext(weapon_data.icon,0,x-618+411*j-122,y-210+165*i+25,0.9,0.9,0,c_white,1)
					//检查是否解锁
					var is_unlocked = is_gem_unlocked(goods_data.unlock_item_id)
					if is_unlocked{
					
						draw_set_color(c_black)
						draw_set_alpha(0.5)
						draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
						draw_set_alpha(1)
						draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
					}
				}
			}
		}
		//绘制道具类型商品
		else if shop_button_select == 3{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var goods_info = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var goods_spr = goods_info.spr
				
				draw_sprite_ext(goods_spr,0,x-618+411*j-122,y-215+165*i+25,1.8,1.8,0,c_white,1)
				
				//判断卡槽物品是否已售完
				if ((goods_info.unlock_item_id == "card_slot" && global.save_data.unlocked_items.max_slot >= 18)
					||(goods_info.unlock_item_id == "card_slot_19" && global.save_data.unlocked_items.max_slot > 18)
					||(goods_info.unlock_item_id == "card_slot_20" && global.save_data.unlocked_items.max_slot > 19)
					||(goods_info.unlock_item_id == "card_slot_21" && global.save_data.unlocked_items.max_slot > 20)
					)
				{
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
				
			}
		}
		//绘制时装类型商品
		if shop_button_select == 4{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var attire_data = get_attire_info(card_data.unlock_item_id)
				draw_sprite_ext(spr_slot, 0, x-618+411*j-122,y-190+165*i, 0.33, 0.33, 0, c_white, 1);
				draw_sprite_ext(attire_data.icon,0,x-618+411*j-122,y-190+165*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_middle);
				draw_set_color(c_black);
				draw_set_font(font_number);
				//draw_text_ext_transformed(x-618+411*j-122-12, y-190+165*i+44, "0",25,1800,1,1,0);
				//draw_sprite_ext(spr_flame, 0, x-618+411*j-122-24, y-190+165*i+43, 0.3, 0.3, 0, c_white, 1);
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查时装是否已解锁
		            var is_unlocked = false;
		            if is_attire_unlocked(card_data.unlock_item_id){
						is_unlocked = true
					}
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
			}
		}
		if shop_button_select == 5{
			if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
				//根据商品id获取卡片信息
				var card_data = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)]
				var attire_data = get_attire_info(card_data.unlock_item_id)
				draw_sprite_ext(attire_data.icon,0,x-618+411*j-122,y-210+165*i+25,1,1,0,c_white,1)
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				// 检查时装是否已解锁
		            var is_unlocked = false;
		            if is_attire_unlocked(card_data.unlock_item_id){
						is_unlocked = true
					}
				if is_unlocked{
					
					draw_set_color(c_black)
					draw_set_alpha(0.5)
					draw_rectangle(x-618+411*j-205,y-190+165*i-82,x-618+411*j+205,y-190+165*i+82,false)
					draw_set_alpha(1)
					draw_sprite_ext(spr_sold_out, 0, x-618+411*j,y-190+165*i, 1.8, 1.8, 0, c_white, 1);
				}
			}
		}
	}
}

if (_pg_live) {
	surface_reset_target()
	draw_surface_ext(pg_surf, 0, 0, 1, 1, 0, c_white, _pg_ease)
}
draw_set_alpha(1)   // 别把透明度漏给收尾

panel_anim_end_slide(id, 260)
