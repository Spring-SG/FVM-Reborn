if global.is_paused{
	image_speed = 0
	exit
	
}
image_speed = 1
x += move_speed
if y > target_y{
	y -= 5
}
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}