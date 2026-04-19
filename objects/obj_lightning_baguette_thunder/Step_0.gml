if global.is_paused{
	exit
}
timer ++
image_index = floor(timer/5) mod 3
if timer >= max_time{
	instance_destroy()
}