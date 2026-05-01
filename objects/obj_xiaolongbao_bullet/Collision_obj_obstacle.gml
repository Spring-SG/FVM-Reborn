if target_type == "normal" && row == other.row{
	if burnt == 0{
		var effect_inst = instance_create_depth(x,y,depth,obj_xiaolongbao_bullet_effect)
		if sprite_index == spr_gatling_popcorn_bullet{
			effect_inst.sprite_index = spr_gatling_popcorn_bullet_effect
		}
		if sprite_index == spr_gatling_popcorn_bullet_1{
			effect_inst.sprite_index = spr_gatling_popcorn_bullet_effect_1
		}
		if sprite_index == spr_gatling_popcorn_bullet_2{
			effect_inst.sprite_index = spr_gatling_popcorn_bullet_effect_2
		}
	}
	else{
		var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
		inst.sprite_index = spr_fire_bullet_effect
	}
	instance_destroy()
}