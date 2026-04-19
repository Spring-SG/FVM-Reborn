if global.is_paused{
	exit
}
timer++
if state == "start"{
	image_index = 0
	y -= 15
	if y <= -200{
		var target_pos = get_world_position_from_grid(target_col,target_row)
		x = target_pos.x 
		y = target_pos.y - room_height
		state = "drop"
	}
}
if state == "drop"{
	image_index = 1
	var target_pos = get_world_position_from_grid(target_col,target_row)
	y += 15
	if y >= target_pos.y{
		var inst = instance_create_depth(x,y-30,0,obj_vajra_lava_effect)
		inst.target_col = target_col
		inst.target_row = target_row
		instance_destroy()
	}
}