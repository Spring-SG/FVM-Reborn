if !hit_enemy{
	if other.hp > 0 and row == other.grid_row  and can_hit(target_type,other.target_type){
		with(other){
			audio_play_sound(snd_egg_bullet,0,0)
			damage_amount = other.damage
			damage_type = other.damage_type
			event_user(0)
			if ice_timer < 600{
				ice_timer = 600
			}
		}
		var effect_inst = instance_create_depth(x,y,depth,obj_iceeggboilerpult_bullet_effect)
		if sprite_index == spr_ice_egg_pisces_bullet{
			effect_inst.sprite_index = spr_ice_egg_pisces_bullet_effect
		}
		hit_enemy = true
		hitted_enemy = other.id
		instance_destroy()
		//// 计算子弹飞行时间（基于水平距离和预设速度）
	    //var distance_x = other.x + global.grid_cell_size_x
	    //var flight_time = 30
    
	    //// 计算子弹所需的速度向量
	    //var total_distance_x = distance_x - x
	    //var total_distance_y = 300//enemy_y - inst.y
    
	    //// 抛物线运动参数计算:cite[6]
	    //move_speed = total_distance_x / flight_time
		//cgravity = (2 * total_distance_y) / (flight_time * flight_time)
	    //cvspeed = (total_distance_y - 0 * cgravity * flight_time * flight_time) / flight_time
	}
}