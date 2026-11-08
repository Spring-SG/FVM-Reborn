if ds_list_find_index(hitted_enemy,other.id) == -1 && !disabled{

	if other.hp > 0 and abs(row - other.grid_row) <= 1  and can_hit(target_type,other.target_type){
		// 边路强化：火焰位于第0行或最后一行时，本路伤害翻倍，相邻行不变
		var _dmg = damage
		if ((row == 0 || row == global.grid_rows - 1) && other.grid_row == row) _dmg *= 2
		with(other){
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
		ds_list_add(hitted_enemy,other.id)
	}
}