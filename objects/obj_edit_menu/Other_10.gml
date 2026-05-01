global.player_name = character_name
if selected_attire_index != -1{
	equip_attire(player_attire_id_list[selected_attire_index])
}
else{
	var current_attire = card_equipped_attire_id("player")
	if current_attire != -1{
		unequip_attire(current_attire)
	}
}