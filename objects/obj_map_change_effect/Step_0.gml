if global.is_paused{
	exit
}
life--

if life <= 0{
	instance_destroy()
}