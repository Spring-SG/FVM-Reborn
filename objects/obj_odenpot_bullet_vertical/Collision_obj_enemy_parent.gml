if ds_list_find_index(hitted_enemy,other.id) == -1{

	if other.hp > 0 and ((shape < 2 && abs(row - other.grid_row)<=4)||shape >= 2)  and can_hit(target_type,other.target_type){
		with(other){
			audio_play_sound(hit_sound,0,0)
			damage_amount = other.damage
			damage_type = other.damage_type
			event_user(0)
	
		}
		ds_list_add(hitted_enemy,other.id)
		//instance_create_depth(x,y,depth,obj_xiaolongbao_bullet_effect)
		//instance_destroy()
	}
}