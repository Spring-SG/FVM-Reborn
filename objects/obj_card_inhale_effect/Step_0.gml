if global.is_paused{
	exit
}
timer++
x += x_move
y += y_move
if timer > 60{
	image_xscale -= 0.03
	image_yscale -= 0.03
	image_alpha -= 0.016
}
if timer >= 120{
	instance_destroy()
}