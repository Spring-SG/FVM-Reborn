image_xscale = 0.9
image_yscale = 0.9

is_submenu_opened = false
shop_button_select = 1
shop_screen_select = 1
current_page = 1
current_max_page = 10

goods_list = ds_list_create()

instance_create_depth(x+795,y-410,depth-1,obj_closecampshop_btn)

var prev_btn = instance_create_depth(x-130,y+428,depth-1,obj_camp_shop_page_btn)
prev_btn.btn_type = "prev"
var next_btn = instance_create_depth(x+130,y+428,depth-1,obj_camp_shop_page_btn)
next_btn.btn_type = "next"

shop_list_recharge()

//刷新商品列表的函数
function shop_list_recharge(){
	ds_list_clear(goods_list)
	
	var map_array = global.goods_id_pool

	//ds_map_keys_to_array(global.goods_map,map_array)

	var goods_array_size = array_length(map_array)

	for(var i = 0; i < goods_array_size;i++){
		//获取营地类型商品
		if shop_button_select == 1{
			if global.goods_map[? map_array[i]].type == "camp"{
				//将商品id添加到商品列表中
				//var card_data = deck_get_card_data(global.goods_map[? map_array[i]].unlock_item_id,0)
				ds_list_add(goods_list,map_array[i])
			}
		}
	}
	//按类型创建购买按钮
	instance_destroy(obj_camp_shop_buy_btn)
	instance_destroy(obj_sold_out_icon)
	for(var i = 0 ; i< 3; i++){
		for(var j = 0; j < 4; j++){
			//绘制卡片类型商品
			if shop_button_select == 1{
				if ds_list_find_value(goods_list,i*4+j+(current_page-1)*12) != undefined{
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
					//根据商品id获取卡片信息
					var inst = instance_create_depth(x-590+380*j+45, y-130+190*i+40,depth-1,obj_camp_shop_buy_btn)
					inst.target_item = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].unlock_item_id
					inst.cost = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].cost
					inst.goods_name = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].display_name
					inst.tooltip_text = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].description
					inst.target_shape = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].target_shape
					inst.coin_type = global.goods_map[? ds_list_find_value(goods_list,i*4+j+(current_page-1)*12)].coin_type
					inst.btn_type = "camp"
					if is_unlocked{
						inst.is_disabled = true
						instance_create_depth(x-590+380*j,y-130+190*i,depth-2,obj_sold_out_icon)
					}
				}
			}
		}
	}
}

// ── 翻页动画：Crossfade + Stagger，参数与商城一致 ──
pg_t        = -1;
pg_frames   = 17;
pg_dir      = 1;
pg_surf     = -1;
pg_old_surf = -1;
pg_switch   = false;

// ── 面板进出场：自下而上滑入 260px + 淡入（GuiStack panel_anim，与其它面板同源）──
panel_anim_init(id, 0.28, 0.18, 260)
panel_anim_kids(id, [obj_closecampshop_btn, obj_camp_shop_page_btn, obj_camp_shop_buy_btn, obj_sold_out_icon])

