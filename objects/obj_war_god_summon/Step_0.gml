if global.is_paused{
	exit
}
timer ++
image_index = floor(timer/5) mod image_number
if timer >= image_number*5-1{
	instance_create_depth(x,y,-800,obj_war_god_soldier)
	instance_destroy()
}