if global.is_paused{
	image_speed = 0
	exit
	
}
image_speed = 1
if burnt == 1{
	sprite_index = spr_fire_bullet
}
y += move_speed
if x > 2200 or y > 1200 or x < 0 or y < -200{
	instance_destroy()
}