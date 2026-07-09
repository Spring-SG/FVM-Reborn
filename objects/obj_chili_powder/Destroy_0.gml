// Inherit the parent event

// alarm[0]事件 - 实际攻击执行
// 摧毁范围内敌人
var _x = x;
var _y = y;
var _range = 250

with (obj_enemy_parent) {
	if (other.shape < 2 && ((grid_row == other.grid_row && abs(x - other.x) <= 2*global.grid_cell_size_x)||(abs(x - other.x) <= 100 && abs(grid_row-other.grid_row) <= 1)))
	||(other.shape >= 2 && (point_distance(x, y, _x, _y) < _range && abs(grid_row-other.grid_row) <= 1)){
		if array_get_index(other.can_mouse_list,mouse_id) != -1 && !can_dropped{
			into_act()
		}
		else{
		    if (immune_to_ash && hp>other.atk) {
		        // 对免疫灰烬的敌人只造成伤害
		        hp -= other.atk;
				event_user(0)
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

var effect_inst2 = instance_create_depth(x,y,depth,obj_coke_bomb_explode)
effect_inst2.sprite_index = spr_chili_powder_explode
if shape < 2{
	var effect_inst = instance_create_depth(x-15,y+15,depth,obj_wine_bottle_bomb_explode)
	effect_inst.col = grid_col
	effect_inst.row = grid_row
	effect_inst.is_parent = true
	effect_inst.interval = 2

	var effect_inst1 = instance_create_depth(x-15,y+15,depth,obj_wine_bottle_bomb_explode)
	effect_inst1.col = grid_col
	effect_inst1.row = grid_row
	effect_inst1.is_parent = true
	effect_inst1.interval = 2
	effect_inst1.type = 1
}
if enemy_encounted{
	for(var i = 0 ; i < 2 ; i++){
		var inst = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
		inst.value = flame_produce
	}
	if shape == 2{
		for(var i = 0 ; i < 2 ; i++){
			var inst2 = instance_create_depth(x, y - 60, depth - 1000, obj_flame);
			inst2.value = flame_produce
		}
	}
}


event_inherited()