if global.is_paused{
	exit
}
timer++
x += x_move
y += y_move
if timer > 0{
	image_xscale -= 0.03
	image_yscale -= 0.03
	image_alpha -= 0.05
}
if timer >= 20{
	instance_destroy()
}