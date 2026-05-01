ice_timer = 0
frozen_timer = 0

if target_card != ""{
	var card_save_data = get_card_info_simple(target_card)
	var card_slot_data = deck_get_card_data(target_card,card_save_data.shape)

	plant_type = card_slot_data[? "plant_type"]
}