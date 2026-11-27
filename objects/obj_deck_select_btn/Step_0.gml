if obj_readyroom_manager.selected_custom_deck == deck_index{
	image_index = 1
}
else{
	image_index = 0
}

deck_name = global.save_data.saved_decks[deck_index-1].name