// Inherit the parent event

	// alarm[0]事件 - 实际攻击执行
	// 摧毁范围内敌人
	var _x = x;
	var _y = y;

	with (obj_enemy_parent) {
		
			if (abs(x - other.x) <= 100||(abs(x - other.x) <= 200 && other.shape >= 2)) {
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
		    }
		}
	}

	// 播放倭瓜攻击效果
	//effect_create_above(ef_explosion, x, y, 2, c_white);

	// 播放攻击声音
	 audio_play_sound(snd_bottle_explode, 0, false);
	 if global.screen_shake{
		Camera_Shock(5,20)
	}
	 
var effect_inst = instance_create_depth(x-15,y+15,depth,obj_wine_bottle_bomb_explode)
effect_inst.col = grid_col
effect_inst.row = grid_row
effect_inst.is_parent = true
effect_inst.type = 1
if shape >= 2{
	if grid_col < global.grid_cols-1{
		var effect_inst1 = instance_create_depth(x-15+global.grid_cell_size_x,y+15,depth,obj_wine_bottle_bomb_explode)
		effect_inst1.col = grid_col
		effect_inst1.row = grid_row
		effect_inst1.is_parent = true
		effect_inst1.type = 1
	}
	if grid_col > 0{
		var effect_inst2 = instance_create_depth(x-15-global.grid_cell_size_x,y+15,depth,obj_wine_bottle_bomb_explode)
		effect_inst2.col = grid_col
		effect_inst2.row = grid_row
		effect_inst2.is_parent = true
		effect_inst2.type = 1
	}
}
event_inherited()