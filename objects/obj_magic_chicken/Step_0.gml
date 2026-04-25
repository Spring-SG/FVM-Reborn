if global.is_paused{
	exit
}

event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

attack_timer++

if attack_timer == 15 * current_flash_speed - 1{
	var card_save_data = get_card_info_simple(target_card)
	if card_save_data != false{
		var prev_card_info = get_plant_data_with_skill(target_card,card_save_data.shape,card_save_data.level,card_save_data.skill)
		var card_slot_data = deck_get_card_data(target_card,card_save_data.shape)
		var grid_pos = get_world_position_from_grid(grid_col,grid_row)
		var new_card = instance_create_depth(grid_pos.x,grid_pos.y,0,card_slot_data[? "obj"])	
		card_created(new_card,grid_col,grid_row)
	}
}

if attack_timer > current_flash_speed * 29 - 1{
	instance_destroy()
}