if global.is_paused{
	exit
}
attack_timer ++
if attack_timer >= 120{
	instance_destroy()
}