var grid_pos = get_grid_position_from_world(x, y);
 var card_shape = get_card_info_simple(card_id).shape
var card_data = deck_get_card_data(card_id,card_shape)
if card_id == "magic_chicken"{
	if global.prev_place_id != ""{
		card_shape = get_card_info_simple(global.prev_place_id).shape
		card_data = deck_get_card_data(global.prev_place_id,card_shape)
	}
}
is_valid = (can_place_at_position(mouse_x, mouse_y, card_data[? "plant_type"],card_data[? "feature_type"],card_data[? "target_card"]));