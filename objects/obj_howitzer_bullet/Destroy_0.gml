	var _x = x;
	var _y = y;
	var _range = 250

	with (obj_enemy_parent) {
		
			if (point_distance(x, y, _x, _y) < _range && grid_row >= other.row-1&&grid_row <= other.row+1) {
		        if (hp>other.damage) {
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

	// 播放倭瓜攻击效果
	//effect_create_above(ef_explosion, x, y, 2, c_white);

	// 播放攻击声音
	 audio_play_sound(snd_bullet_explode, 0, false);
	 
var effect_inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)

if get_gem_index("transform_gem")!= -1{
	var f_value = get_gem_info("transform_gem").value[get_gem_level("transform_gem")]
	var f_inst = instance_create_depth(x,y,-2000,obj_flame)
	f_inst.value = f_value
}
ds_list_destroy(brazier_list)
