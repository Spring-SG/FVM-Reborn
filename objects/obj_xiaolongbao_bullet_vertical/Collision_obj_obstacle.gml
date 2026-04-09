if target_type == "normal"{
	if burnt == 0{
		instance_create_depth(x,y,depth,obj_xiaolongbao_bullet_effect)
	}
	else{
		var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
		inst.sprite_index = spr_fire_bullet_effect
	}
	instance_destroy()
}