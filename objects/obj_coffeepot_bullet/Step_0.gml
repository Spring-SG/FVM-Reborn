if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}
attack_timer ++
//x += move_speed
if shape>=2{
	sprite_index = spr_coffeepot_bullet_2
}
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}