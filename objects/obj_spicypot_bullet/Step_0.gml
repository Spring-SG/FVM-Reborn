if global.is_paused{
	exit
}
x += move_speed
timer++
if timer <= 4* 3 - 1{
	image_index = floor(timer/3) mod 4
}
else{
	image_index = floor(timer/5) mod 10 + 4
}
col = get_grid_position_from_world(x,y).col
if ((col >= start_col + 4)&& shape <= 1 )||(col >= start_col + 5){
	disabled = true
}
if disabled{
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}

if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}