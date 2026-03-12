// Inherit the parent event

	// alarm[0]事件 - 实际攻击执行
	// 摧毁范围内敌人
	var _x = x;
	var _y = y;
	var _range = 250
	
	if shape == 2{
		var start_pos_x = x + 13 -global.grid_cell_size_x
		var start_pos_y = y - 32 - global.grid_cell_size_y
		for(var i = 0; i < 3;i++){
			for(var j= 0 ; j < 3;j++){
				var grid_pos = get_grid_position_from_world(start_pos_x + j * global.grid_cell_size_x,start_pos_y + i * global.grid_cell_size_y)
				if grid_pos.row >= 0 && grid_pos.row < global.grid_rows && grid_pos.col >= 0 && grid_pos.col < global.grid_cols{
					var inst = instance_create_depth(start_pos_x + j * global.grid_cell_size_x,start_pos_y + i * global.grid_cell_size_y,depth,obj_burn_effect)
					inst.damage = 5
					inst.max_time = 300
				}
			}
		}
		
	}

	with (obj_enemy_parent) {
		
		
		if (point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-1&&grid_row <= other.grid_row+1) {
			if array_get_index(other.can_mouse_list,mouse_id) != -1 && ! can_dropped{
			
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
	 
var effect_inst = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
if shape == 0 {
	effect_inst.sprite_index = spr_coke_bomb_explode
}
else if shape == 1{
	effect_inst.sprite_index = spr_coke_bomb_explode_1
}
else if shape == 2{
	effect_inst.sprite_index = spr_coke_bomb_explode_2
}
event_inherited()