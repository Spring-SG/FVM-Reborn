if global.is_paused{
	exit
}
if global.debug{
	cooldown_timer = 0
}
if cooldown_timer>0 cooldown_timer--