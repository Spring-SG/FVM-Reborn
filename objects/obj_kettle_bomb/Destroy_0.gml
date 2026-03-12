// Inherit the parent event
if state == CARD_STATE.IDLE{
	// alarm[0]事件 - 实际攻击执行
	// 摧毁范围内敌人
	var _x = x;
	var _y = y;
	var _range = 350
	
	audio_stop_sound(snd_kettle_bomb_explode)
	
	with (obj_enemy_parent) {
		
		
		if (point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-2&&grid_row <= other.grid_row+2) {
			if array_get_index(other.can_mouse_list,mouse_id) != -1 && !can_dropped{
		into_act()
		}
		else{
		        if (immune_to_ash && hp>other.atk) {
		            // 对免疫灰烬的敌人只造成伤害
		            hp -= other.atk;
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
				if other.shape >= 2{
					if ice_timer < 600{
						ice_timer = 600
					}
				}
		    }
		}
	}

	// 播放倭瓜攻击效果
	//effect_create_above(ef_explosion, x, y, 2, c_white);

	// 播放攻击声音
	 audio_play_sound(snd_coke_bomb_explode, 0, false);
	 if global.screen_shake{
		Camera_Shock(5,20)
	}
	if global.screen_flash{
		screen_flash(c_purple,20)
	}
	 
	var effect_inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
	if shape == 0 {
		effect_inst.sprite_index = spr_kettle_bomb_explode
	}
	else if shape == 1{
		effect_inst.sprite_index = spr_kettle_bomb_explode_1
	}
	else if shape == 2{
		effect_inst.sprite_index = spr_kettle_bomb_explode_2
	}

}
	event_inherited()