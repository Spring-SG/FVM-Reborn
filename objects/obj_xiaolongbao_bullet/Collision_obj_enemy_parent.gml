

	if other.hp > 0 and row == other.grid_row and can_hit(target_type,other.target_type){
		with(other){
			if other.burnt == 1{
				audio_play_sound(snd_fire_hit,0,0)
			}
			else{
				audio_play_sound(hit_sound,0,0)
			}
			damage_amount = other.damage
			damage_type = other.damage_type
			event_user(0)
	
		}
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
