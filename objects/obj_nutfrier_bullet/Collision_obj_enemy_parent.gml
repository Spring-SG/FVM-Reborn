if other.hp > 0 and can_hit(target_type,other.target_type) and (b_type == 0 ||(b_type == 1 && row == other.grid_row)){
	with(other){
		if other.burnt == 1{
			global.audio.play(snd_fire_hit,0,0)
		}
		else{
			global.audio.play(hit_sound,0,0)
		}
		damage_amount = other.damage
		damage_type = other.damage_type
		event_user(0)
	
	}
	if burnt == 0{
		var inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
		if sprite_index == spr_nut_frier_bullet{
			inst.sprite_index = spr_nut_frier_bullet_effect
		}
		else if sprite_index == spr_nut_frier_bullet_1{
			inst.sprite_index = spr_nut_frier_bullet_effect_1
		}
		else if sprite_index == spr_nut_frier_bullet_2{
			inst.sprite_index = spr_nut_frier_bullet_effect_2
		}
	}
	else{
		var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
		inst.sprite_index = spr_fire_bullet_effect
	}
	instance_destroy()
}
