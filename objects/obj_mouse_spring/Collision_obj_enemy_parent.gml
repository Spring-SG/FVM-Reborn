if array_get_index(enemy_list,other.id) == -1 && array_get_index(ignore_list,other.mouse_id) == -1 && state == "idle" && row == other.grid_row && (other.target_type == "normal" || other.target_type == "dance") && left_use_times > 0{
	array_push(enemy_list,other.id)
	
	array_push(enemy_left_time,30)
	other.stun_timer = 30
	
	left_use_times --
	state = "act"
	timer = 0
}