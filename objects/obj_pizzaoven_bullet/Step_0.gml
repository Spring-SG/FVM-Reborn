if global.is_paused{
	image_speed = 0
	exit	
}
image_speed = 1


if state == "move"{
	x += move_speed
	if x >= target_x{
		state = "target"
	}
}
else{
	if instance_exists(target_enemy){
		if x > target_enemy.x{
			x -= 8
		}
	}
	timer ++
	if timer <= 180 && timer mod 12 == 1{
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
	if timer > 180{
		image_alpha -= 0.1
		if image_alpha <= 0{
			instance_destroy()
		}
	}
}

if x > 2200 or y > 1200 or x < 0 or y < 0{
	instance_destroy()
}