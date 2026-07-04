if global.is_paused{
	image_speed = 0
	exit
}
else{
	image_speed = 1
}
attack_timer ++
if attack_timer == 2{
	with obj_enemy_parent{
		if place_meeting(x,y,other){

			if hp > 0 and other.row == grid_row  and can_hit(other.target_type,target_type){
				
				audio_play_sound(hit_sound,0,0)
				damage_amount = other.damage
				damage_type = other.damage_type
				event_user(0)
	
			}
		}
	}
}
//x += move_speed
if shape>=2{
	sprite_index = spr_coffeepot_bullet_2
}
if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}