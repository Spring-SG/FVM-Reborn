if global.is_paused{
	exit
}

timer ++
image_index = floor(timer/5) mod 3
if b_type == 0{
	x += move_speed
	with obj_card_parent{
		if abs(x-other.x) <= 50 && grid_row == other.grid_row{
			var inst = instance_create_depth(x,y-35,-800,obj_arno_bullet_effect)
			inst.sprite_index = spr_mouse_train_1_bullet_effect
			instance_destroy(other)
			if plant_id != "player" && plant_type != "coffee" && !invincible{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
	}
}
else if b_type == 1{
	y += move_speed
	with obj_card_parent{
		if abs(y-other.y) <= 50 && grid_col == other.grid_col{
			var inst = instance_create_depth(x,y-35,-800,obj_arno_bullet_effect)
			inst.sprite_index = spr_mouse_train_1_bullet_effect
			instance_destroy(other)
			if plant_id != "player" && plant_type != "coffee" && !invincible{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
	}
}
else if b_type == 2{
	x += move_speed * cos(degtorad(image_angle))
	y -= move_speed * sin(degtorad(image_angle))
	with obj_card_parent{
		if place_meeting(x,y,other){
			var inst = instance_create_depth(x,y-35,-800,obj_arno_bullet_effect)
			inst.sprite_index = spr_mouse_train_1_bullet_effect
			instance_destroy(other)
			if plant_id != "player" && plant_type != "coffee" && !invincible && plant_id != "cotton_candy"{
				if hp >= max_hp{
					obj_task_manager.card_loss++
				}
				instance_destroy()
			}
		}
	}
}
if x < -200 || x > 2200 || y < -200 || y > 1200{
	instance_destroy()
}