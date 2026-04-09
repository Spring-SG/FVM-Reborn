// Inherit the parent event
event_inherited();

if hp <= 0.33 * max_hp{
	sprite_index = spr_list[2]
}
else if hp <= 0.67 * max_hp{
	sprite_index = spr_list[1]
}
else{
	sprite_index = spr_list[0]
}

depth = calculate_plant_depth(grid_col,grid_row,"lilypad")
