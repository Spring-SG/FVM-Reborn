var _damage = damage 
if other.hp > 0 and row == other.grid_row  and can_hit(target_type,other.target_type){
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
		inst.sprite_index = spr_cactus_sashimi_bullet_effect
	}
	else if burnt == 1{
		var inst = instance_create_depth(x+25,y,depth,obj_fire_bullet_effect)
		inst.sprite_index = spr_fire_bullet_effect
	}
	instance_destroy()
}