// obj_plant_parent 的 Step 事件
if global.is_paused{
	exit
}

grid_row = parent_player.grid_row
grid_col = parent_player.grid_col
depth = parent_player.depth-1

timer++

if produce_gem{
	if not first_produce{
		if timer mod first_produce_delay == 0{
			var f_inst = instance_create_depth(x,y-50,-1300,obj_flame)
			f_inst.value = flame_produce
			first_produce = true
		}
	}
	else{
		if timer mod cycle == 0{
			var f_inst = instance_create_depth(x,y-50,-1300,obj_flame)
			f_inst.value = flame_produce
		}
	}
}
if slow_down_gem{
	if timer mod slow_down_cycle == 0{
		var start_pos_x = x + 10 - global.grid_cell_size_x
		var start_pos_y = y - 35 - global.grid_cell_size_y
		for(var i = 0; i < 3;i++){
			for(var j= 0 ; j < 3;j++){
				var grid_pos = get_grid_position_from_world(start_pos_x + j * global.grid_cell_size_x,start_pos_y + i * global.grid_cell_size_y)
				if grid_pos.row >= 0 && grid_pos.row < global.grid_rows && grid_pos.col >= 0 && grid_pos.col < global.grid_cols{
					var inst = instance_create_depth(start_pos_x + j * global.grid_cell_size_x,start_pos_y + i * global.grid_cell_size_y,depth,obj_slowdown_gem_effect)
					inst.row = grid_row -1+i
				}
			}
		}
	}
}
if bleed_gem{
	if timer mod 60 == 0{
			var _x = x;
			var _y = y;
			var _range = 250
		with (obj_enemy_parent) {
		
			if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row >= other.grid_row-1&&grid_row <= other.grid_row+1) {
			    hp -= other.bleed_damage
				event_user(0)
		}
		
	}
	}
}
if guard_gem || strength_gem{
	with (obj_card_parent){
		if(grid_row >= other.grid_row-1&&grid_row <= other.grid_row+1&&grid_col >= other.grid_col-1&&grid_col<=other.grid_col+1&&plant_id!="player"){
			if other.guard_gem{
				if (array_get_index(other.hp_modified_card_list,id)==-1){
					max_hp += other.max_hp_increase
					array_push(other.hp_modified_card_list,id)
				}
				if other.timer mod 60 == 0{
					if hp < max_hp - 10{
						hp += 10
						instance_create_depth(x,y+30,depth-4,obj_card_heal_effect)
					}
					else if hp < max_hp{
						hp = max_hp
						instance_create_depth(x,y+30,depth-4,obj_card_heal_effect)
					}
				}
			}
			// 蓄力宝石只增幅输出卡片：水果塔/火盆的 atk 本身就是加成倍率，
			// 放大会滚雪球式放大它们影响的所有卡片，因此排除在外
			var _atk_buff_immune = (plant_id == "fruit_tart" || plant_id == "brazier")
			if other.strength_gem && !_atk_buff_immune && (array_get_index(other.atk_modified_card_list,id)==-1){
				atk = atk*(other.atk_ratio+1)
				array_push(other.atk_modified_card_list,id)
			}
		}
	}
}

