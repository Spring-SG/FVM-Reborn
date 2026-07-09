if global.is_paused{
	exit
}
timer++
var target_pos = get_world_position_from_grid(target_col,target_row)
y += 5
if y >= target_pos.y{
	with obj_card_parent{
		if (abs(grid_col - other.target_col) <= 0 && grid_row == other.target_row) &&plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			instance_destroy()
		}
	}
	var effect = instance_create_depth(x,y-25,-200,obj_coke_bomb_explode)
	effect.sprite_index = spr_machine_bomb_mouse_bomb_effect
	instance_destroy()
}