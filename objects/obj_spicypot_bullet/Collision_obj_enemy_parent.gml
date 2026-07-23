if timer mod 12 == 1 && !disabled{

	if other.hp > 0 and abs(row - other.grid_row) <= 1  and can_hit(target_type,other.target_type){
		with(other){
			if hp > other.damage{
				audio_play_sound(snd_fire_hit,0,0)
				damage_amount = other.damage
				damage_type = other.damage_type
				event_user(0)
			}
			else{
				if special_ash{
					var inst = instance_create_depth(x,y-20,depth,obj_mouse_ash_death)
					inst.special_ash = true
					inst.sprite_index = sprite_index
					inst.image_index = image_index
				}
				else{
					instance_create_depth(x,y-20,depth,obj_mouse_ash_death)
				}
				instance_destroy()
			}
		}
	}
}