	var _x = x
	var _y = y
	if instance_exists(hitted_enemy){
		_x = hitted_enemy.x;
		_y = hitted_enemy.y;
	}
	var _range = 200;
	var splash_ratio = 0.35
	if shape >= 1{
		splash_ratio = 0.5
	}

	with (obj_enemy_parent) {
	    if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row <= other.row+1&& grid_row >= other.row-1 && id != other.hitted_enemy  and can_hit(other.target_type,target_type)) {
	        
	        // 对敌人造成溅射伤害
	        damage_amount = other.damage * splash_ratio
			damage_type = other.damage_type
			event_user(0)
	        
	    }
	}
	audio_play_sound(snd_egg_bullet,0,0)