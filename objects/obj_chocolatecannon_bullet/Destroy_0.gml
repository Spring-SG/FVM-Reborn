var _x = x;
	var _y = y;
	var _range = 250

	with (obj_enemy_parent) {
		
		
		if (point_distance(x, y, _x, _y) < _range && grid_row >= other.target_row-1&&grid_row <= other.target_row+1) {
			if array_get_index(other.can_mouse_list,mouse_id) != -1 && !can_dropped{
				into_act()
			}
			else{
		        if (immune_to_ash && hp>other.damage) {
		            // 对免疫灰烬的敌人只造成伤害
		            hp -= other.damage;
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
	}