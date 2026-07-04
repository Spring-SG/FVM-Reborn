var target_inst = noone
for(var i = 0;i < array_length(target_enemy);i++){
	if shape >= 1{
		target_inst = target_enemy[i]
	}
	else{
		target_inst = target_enemy[0]
	}
	if instance_exists(target_inst){
		with target_inst{
			if can_hit(other.target_type,target_type){
				if hp > 0{
					damage_amount = other.atk
					damage_type = "normal"
					event_user(0)
					audio_play_sound(hit_sound,0,0)
				}
			}
		}
	}
	if shape == 0{
		break
	}
}
target_enemy = []