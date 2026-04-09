if global.is_paused{
	image_speed = 0
}
else{
	image_speed = 1
}
//x += move_speed
if shape>=2{
	sprite_index = spr_odenpot_bullet_2
}
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}