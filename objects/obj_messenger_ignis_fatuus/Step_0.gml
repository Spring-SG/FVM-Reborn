if global.is_paused{
	exit
}
timer++
if state == "appear"{
	image_index = floor(timer/5) mod 7
	if timer >= 7 * 5 - 1{
		timer = 0
		state = "move"
	}
}
if state == "move"{
	image_index = floor(timer/5) mod 10 + 7
	y += y_move
	if timer >= 120{
		timer = 0
		state = "disappear"
	}
}
if state == "disappear"{
	image_index = floor(timer/5) mod 8 + 17
	if timer >= 8*5-1{
		instance_create_depth(x,y,depth,obj_ghost_mouse)
		instance_destroy()
	}
}