if not obj_camp_shop_bg.is_submenu_opened and not is_disabled{
	
	global.audio.play(snd_button,0,0)
	if btn_type == "camp"{
		if get_card_info_simple(target_item).shape != target_shape - 1{
			show_notice("请先购买一转",60)
			exit
		}
		if get_material_amount(coin_type) >= cost || global.debug{
			var inst = instance_create_depth(room_width/2,room_height/2,depth-3,obj_camp_shop_buy_confirm)
			inst.banding_buy_btn = id
			obj_camp_shop_bg.is_submenu_opened = true
			//show_debug_message(global.save_data.player.gold)
		}
		else{
			show_notice("营地货币不足",60)
		}
	}
}