if not obj_shop_bg.is_submenu_opened and not is_disabled{
	
	audio_play_sound(snd_button,0,0)
	if btn_type == "card" || btn_type == "weapon" || btn_type == "gem" || btn_type == "attire"{
		if global.save_data.player.gold >= cost || global.debug{
			var inst = instance_create_depth(room_width/2,room_height/2,depth-3,obj_shop_buy_confirm)
			inst.banding_buy_btn = id
			obj_shop_bg.is_submenu_opened = true
			//show_debug_message(global.save_data.player.gold)
		}
		else{
			show_notice("金币不足",60)
		}
	}
	else if btn_type == "item"{
		if global.save_data.player.gold >= cost || global.debug{
			if target_item == "card_slot_21" && global.save_data.unlocked_items.max_slot != 20{
				show_notice("请先购买第20个卡槽",60)
			}
			else if target_item == "card_slot_20" && global.save_data.unlocked_items.max_slot != 19{
				show_notice("请先购买第19个卡槽",60)
			}
			else if target_item == "card_slot_19" && global.save_data.unlocked_items.max_slot != 18{
				show_notice("请先购买前18个卡槽",60)
			}
			else{
				var inst = instance_create_depth(room_width/2,room_height/2,depth-3,obj_shop_buy_confirm)
				inst.banding_buy_btn = id
				obj_shop_bg.is_submenu_opened = true
				//show_debug_message(global.save_data.player.gold)
			}
		}
		else{
			show_notice("金币不足",60)
		}
	}
}