if global.is_paused{
	exit
}
timer++
var target_x = get_world_position_from_grid(target_col,target_row).x

if x > 2200 or y > 1200 or x < -200 or y < -200{
	instance_destroy()
}

x += move_speed
y -= cvspeed

if x >= target_x - 10 && x <= target_x + 10{
	with obj_card_parent{
		if grid_col - other.target_col <= 1 && grid_row - other.target_row <= 1 &&
		grid_col >= other.target_col && grid_row >= other.target_row &&
		plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
			if hp >= max_hp{
				obj_task_manager.card_loss++
			}
			instance_destroy()
		}
	}
	var inst = instance_create_depth(x+50,y-65,-800,obj_coke_bomb_explode)
	inst.sprite_index = spr_spider_man_mouse_web_effect
	instance_destroy()
	
}