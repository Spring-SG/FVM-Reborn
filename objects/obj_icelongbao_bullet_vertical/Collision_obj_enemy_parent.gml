
if other.hp > 0   and can_hit(target_type,other.target_type){
	with(other){
		if other.burnt == 2{
				audio_play_sound(snd_fire_hit,0,0)
			}
			else{
				audio_play_sound(hit_sound,0,0)
			}
		damage_amount = other.damage
		damage_type = other.damage_type
		if shield_hp <= 0{
			if ice_timer <= 600 && other.burnt == 0{
				ice_timer = 600
			}
		}
		event_user(0)
	
	}
	if burnt == 0{
		instance_create_depth(x,y,depth,obj_icelongbao_bullet_effect)
	}
	else if burnt == 1{
		instance_create_depth(x,y,depth,obj_xiaolongbao_bullet_effect)
	}
	else if burnt == 2{
		var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
		inst.sprite_index = spr_fire_bullet_effect
	}
	instance_destroy()
}