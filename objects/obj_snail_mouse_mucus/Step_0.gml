if global.is_paused{
	exit
}
timer++
if state == "start"{
	if timer == 1{
		var target_pos = get_world_position_from_grid(target_col,target_row)
		banding_lava_obj = instance_create_depth(target_pos.x,target_pos.y-35,-1200,obj_mucus)
		banding_lava_obj.row = target_row
		banding_lava_obj.col = target_col
		banding_lava_obj.depth = calculate_plant_depth(target_col,target_row,"coffee")
	}
	if timer <= 6 * 5 - 1{
		image_index = floor(timer/5) mod 6
	}
	else{
		image_index = 5
	}
	if timer >= 30 * 60{
		timer = 0
		state = "drop"
	}
}
if state == "drop"{
	if instance_exists(banding_lava_obj){
		instance_destroy(banding_lava_obj)
	}
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}