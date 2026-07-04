if target_type == "normal" && row == other.row{
	if burnt == 0{
		var inst = instance_create_depth(x,y,depth,obj_coffeecup_bullet_effect)
		inst.sprite_index = spr_triplewinerack_bullet_effect
		if sprite_index == spr_wine_rack_sagittarius_bullet{
			inst.sprite_index = spr_wine_rack_sagittarius_bullet_effect
		}
		if sprite_index == spr_wine_rack_sagittarius_bullet_1{
			inst.sprite_index = spr_wine_rack_sagittarius_bullet_effect_1
		}
	}
	else if burnt == 1{
		var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
		inst.sprite_index = spr_fire_bullet_effect
	}
	instance_destroy()
}