if array_get_index(enemy_list,other.id) == -1 && array_get_index(ignore_list,other.mouse_id) == -1 && state == "act" && row == other.grid_row && (other.target_type == "normal" || other.target_type == "dance") && other.x >= x - 60{
	array_push(enemy_list,other.id)
	if other.x > x+20{
		array_push(enemy_left_time,38)
		other.stun_timer = 38
	}
	else{
		array_push(enemy_left_time,30)
		other.stun_timer = 30
	}
}