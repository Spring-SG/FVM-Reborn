if ds_list_find_index(hitted_enemy,other.id) == -1 && row == other.grid_row{
	with other{
		if array_get_index(other.can_mouse_list,mouse_id) != -1 && !can_dropped{
			into_act()
		}
		else{
			if (immune_to_ash && hp>900) {
				// 对免疫灰烬的敌人只造成伤害
				hp -= 900;
				event_user(0)
				// 受伤效果
				//effect_create_above(effect_smoke, x, y, 1, c_gray);
			} else {
				// 直接摧毁非免疫敌人
				if special_ash{
					var inst = instance_create_depth(x,y-20,depth,obj_mouse_ash_death)
					inst.special_ash = true
					inst.sprite_index = sprite_index
					inst.image_index = image_index
				}
				else{
					instance_create_depth(x,y-20,depth,obj_mouse_ash_death)
				}
				instance_destroy();
				// 摧毁效果
				//effect_create_above(ef_explosion, x, y, 1, c_yellow);
			}
		}
	}
	ds_list_add(hitted_enemy,other.id)
}
