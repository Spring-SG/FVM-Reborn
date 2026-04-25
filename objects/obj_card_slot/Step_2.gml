if card_id == "magic_chicken"{
	if global.prev_place_id != ""{
		var card_save_data = get_card_info_simple(global.prev_place_id)
		if card_save_data != false{
			var prev_card_info = get_plant_data_with_skill(global.prev_place_id,card_save_data.shape,card_save_data.level,card_save_data.skill)
			if cooldown_timer >= cooldown{
				cooldown = prev_card_info[? "cooldown"]
				if cooldown < 13.5 * 60{
					cooldown = 13.5 * 60
				}
				cooldown_timer = cooldown
			}
			cost = prev_card_info[? "cost"]
			if ds_map_find_value(global.plus_card_map,global.prev_place_id) != undefined{
				current_cost = cost
				var plus_info = ds_map_find_value(global.plus_card_map,global.prev_place_id)
				with plus_info[0]{
					if card_save_data.shape < plus_info[1]{
						other.current_cost += 50
					}
				}
			}
			var card_slot_data = deck_get_card_data(global.prev_place_id,card_save_data.shape)
			card_spr = card_slot_data[? "sprite"]
			//place_preview = card_slot_data[? "place_preview"]
			//card_obj = card_slot_data[? "obj"]
		}
	}
}