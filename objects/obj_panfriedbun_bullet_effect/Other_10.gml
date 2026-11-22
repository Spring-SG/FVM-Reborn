var _x = x;
var _y = y;
var _range = 200

if shape < 1{
	with (obj_enemy_parent) {	
		if (hp > 0 && ((abs(x - other.x) <= 1.5 * global.grid_cell_size_x && grid_row == other.grid_row) || (abs(grid_row-other.grid_row) <= 1 && abs(x - other.x) <= 100)) and can_hit(other.target_type,target_type)) {
			// 边路强化：火焰位于第0行或最后一行时，本路伤害翻倍，其他路不变
			var _dmg = other.damage
			if ((other.grid_row == 0 || other.grid_row == global.grid_rows - 1) && grid_row == other.grid_row) _dmg *= 2
			if hp > _dmg{
				global.audio.play(snd_fire_hit,0,0)
				damage_amount = _dmg
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
else{
	with (obj_enemy_parent) {	
		if (hp > 0 && (abs(grid_row-other.grid_row) <= 1 && abs(x - other.x) <= 200) and can_hit(other.target_type,target_type)) {
			// 边路强化：火焰位于第0行或最后一行时，本路伤害翻倍，其他路不变
			var _dmg = other.damage
			if ((other.grid_row == 0 || other.grid_row == global.grid_rows - 1) && grid_row == other.grid_row) _dmg *= 2
			if hp > _dmg{
				global.audio.play(snd_fire_hit,0,0)
				damage_amount = _dmg
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
