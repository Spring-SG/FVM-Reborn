if global.is_paused{
	exit
}

x -= 0.25

var grid_pos = get_grid_position_from_world(x,y)
col = grid_pos.col
row = grid_pos.row

var target_pos = get_world_position_from_grid(1,0)

if x > target_pos.x{
	if !is_hole && image_alpha < 1{
		image_alpha += 0.1
	}
}
else{
	image_alpha -= 0.1
	if image_alpha <= 0{
		instance_destroy()
	}
}

if is_hole && col > 1{
	with obj_card_parent{
		if grid_col == other.col && grid_row == other.row &&
		plant_id != "player" && plant_type != "coffee"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			var inst = instance_create_depth(x,y,depth,obj_drop_death_effect)
			inst.sprite_index = sprite_index
			inst.image_index = image_index
			instance_destroy()
		}
	}
	with obj_enemy_parent{
		if grid_col == other.col && grid_row == other.row && 
		array_get_index(other.ignore_list,mouse_id) == -1 && (target_type == "normal" || target_type == "dance" || target_type == "obstacle"){
			var inst = instance_create_depth(x,y,depth,obj_drop_death_effect)
			inst.sprite_index = sprite_index
			inst.image_index = image_index
			instance_destroy()
		}
	}
}