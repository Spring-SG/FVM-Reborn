// Inherit the parent event
event_inherited();
if shape == 1{
	sprite_index = spr_large_fire_1
}
else if shape == 2{
	sprite_index = spr_large_fire_2
}
if card_equipped_attire_id(plant_id) != -1{
	var spr_list = get_attire_info(card_equipped_attire_id(plant_id)).spr
	sprite_index = spr_list[shape]
}