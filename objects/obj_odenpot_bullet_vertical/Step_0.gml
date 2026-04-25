if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}
attack_timer ++
//x += move_speed
if attack_timer == 2{
	with obj_enemy_parent{
		if place_meeting(x,y,other){
			if ds_list_find_index(other.hitted_enemy,id) == -1{

				if hp > 0 and ((other.shape < 2 && abs(other.row - grid_row)<=4)||other.shape >= 2)  and can_hit(other.target_type,target_type){
					audio_play_sound(hit_sound,0,0)
					damage_amount = other.damage
					damage_type = other.damage_type
					event_user(0)
					ds_list_add(other.hitted_enemy,id)
				}
			}
		}
	}
}
if shape>=2{
	sprite_index = spr_odenpot_bullet_2
}
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}