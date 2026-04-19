if global.is_paused{
	exit
}
timer ++
image_index = floor(timer/5) mod 2
if timer > 30{
	instance_destroy()
}