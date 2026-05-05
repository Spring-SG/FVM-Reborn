// Inherit the parent event

if hp > maxhp - helmet_hp{
	sprite_index = spr_machine_iron_pan_mouse_helmet
	hit_sound = snd_hit3
}
else{
	sprite_index = spr_machine_iron_pan_mouse
	hit_sound = snd_hit1
}
if hp <= maxhp - helmet_hp && not armor_dropped{
	var inst = instance_create_depth(x-45,y-175,depth-1,obj_enemy_armor)
	inst.ground_y = y - 45
	inst.type = "helmet"
	inst.x_speed = random_range(3,5)
	inst.y_speed = random_range(-5,-8)
	inst.cgravity = 0.8
	inst.sprite_index = spr_pan_helmet
	armor_dropped = true
}

event_inherited();