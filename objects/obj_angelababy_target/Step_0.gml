if global.is_paused{
	exit
}

timer ++
image_index = floor(timer/3) mod 10
if timer >= 29{
	instance_create_depth(x+30,y-150,-800,obj_angelababy_diamond)
	instance_destroy()
}