if global.is_paused{
	image_speed = 0
}
else{
	image_speed = 1
}
if !instance_exists(banding_card_obj){
	instance_destroy()
}