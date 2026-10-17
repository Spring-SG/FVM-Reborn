if global.is_paused{
	exit
}
timer++
if timer < 35*5{
	image_index = floor(timer/5)
}
else{
	image_alpha = 0
}
with obj_card_parent{
	if hp < max_hp{
		hp = max_hp
		instance_create_depth(x,y+30,depth-4,obj_card_heal_effect)
	}
}
if timer >= max_time{
	instance_destroy()
}