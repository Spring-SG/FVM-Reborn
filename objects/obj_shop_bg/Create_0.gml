image_xscale = 1.8
image_yscale = 1.8

is_submenu_opened = false
shop_button_select = 1
shop_screen_select = 1
current_page = 1
current_max_page = 10

goods_list = ds_list_create()

instance_create_depth(x+800,y-430,depth-1,obj_closeshop_btn)

//创建商店栏位选择按钮
var btn1 = instance_create_depth(x-743,y-363,depth-1,obj_shop_select_btn)
btn1.button_index = 1
btn1.sprite_index = spr_shop_select_btn_1
var btn2 = instance_create_depth(x-560,y-363,depth-1,obj_shop_select_btn)
btn2.button_index = 2
btn2.sprite_index = spr_shop_select_btn_2
var btn3 = instance_create_depth(x-377,y-363,depth-1,obj_shop_select_btn)
btn3.button_index = 3
btn3.sprite_index = spr_shop_select_btn_3

var prev_btn = instance_create_depth(x+285,y+435,depth-1,obj_shop_page_btn)
prev_btn.btn_type = "prev"
var next_btn = instance_create_depth(x+485,y+435,depth-1,obj_shop_page_btn)
next_btn.btn_type = "next"

shop_list_recharge()

//刷新商品列表的函数
function shop_list_recharge(){
	ds_list_clear(goods_list)
	
	var map_array = []

	ds_map_keys_to_array(global.goods_map,map_array)

	var goods_array_size = array_length(map_array)

	for(var i = 0; i < goods_array_size;i++){
		//获取卡片类型商品
		if shop_button_select == 1{
			if global.goods_map[? map_array[i]].type == "card"{
				//将商品id添加到商品列表中
				//var card_data = deck_get_card_data(global.goods_map[? map_array[i]].unlock_item_id,0)
				ds_list_add(goods_list,map_array[i])
			}
		}
		//获取道具类型商品
		else if shop_button_select == 3{
			if global.goods_map[? map_array[i]].type == "item"{
				//将商品id添加到商品列表中
				//var card_data = deck_get_card_data(global.goods_map[? map_array[i]].unlock_item_id,0)
				ds_list_add(goods_list,map_array[i])
			}
		}
		//获取武器和宝石商品
		else if shop_button_select == 2{
			if global.goods_map[? map_array[i]].type == "weapon" || global.goods_map[? map_array[i]].type == "gem"{
				//将商品id添加到商品列表中
				//var card_data = deck_get_card_data(global.goods_map[? map_array[i]].unlock_item_id,0)
				ds_list_add(goods_list,map_array[i])
			}
		}
	}
	//按类型创建购买按钮
	instance_destroy(obj_shop_buy_btn)
	for(var i = 0 ; i< 4; i++){
		for(var j = 0; j < 4; j++){
			//绘制卡片类型商品
			if shop_button_select == 1{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
					// 检查卡片是否已解锁
		            var is_unlocked = false;
		            for(var k = 0; k < array_length(global.save_data.unlocked_cards); k++) {
		                if (global.save_data.unlocked_cards[k].id == global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id) {
		                    is_unlocked = true;
		                    break;
		                }
		            }
					//根据商品id获取卡片信息
					var inst = instance_create_depth(x-618+411*j+77, y-190+165*i+60,depth-1,obj_shop_buy_btn)
					inst.target_item = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id
					inst.cost = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].cost
					inst.goods_name = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].display_name
					inst.tooltip_text = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].description
					inst.btn_type = "card"
					if is_unlocked{
						inst.is_disabled = true
					}
				}
			}
			else if shop_button_select == 2{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
					// 检查商品类型
		            var is_unlocked = false
					var goods_type = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].type
					if goods_type == "weapon"{
						is_unlocked = is_weapon_unlocked(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id)
					}
					else if goods_type == "gem"{
						is_unlocked = is_gem_unlocked(global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id)
					}
					//根据商品id获取宝石或武器信息
					var inst = instance_create_depth(x-618+411*j+77, y-190+165*i+60,depth-1,obj_shop_buy_btn)
					inst.target_item = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id
					inst.cost = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].cost
					inst.goods_name = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].display_name
					inst.tooltip_text = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].description
					inst.btn_type = goods_type
					if is_unlocked{
						inst.is_disabled = true
					}
				}
			}
			else if shop_button_select == 3{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*16) != undefined{
					
					//根据商品id获取商品信息
					var inst = instance_create_depth(x-618+411*j+77, y-190+165*i+60,depth-1,obj_shop_buy_btn)
					inst.target_item = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].unlock_item_id
					inst.cost = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].cost
					inst.goods_name = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].display_name
					inst.tooltip_text = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*16)].description
					inst.btn_type = "item"
					
				}
			}
		}
	}
}