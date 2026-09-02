if global.is_paused{
	exit
}
timer++
if state == "start"{
	image_index = floor(timer/5) mod 4
	y -= 15
	if y <= -200{
		var target_pos = get_world_position_from_grid(target_col,target_row)
		x = target_pos.x 
		y = target_pos.y - room_height
		state = "drop"
	}
}
if state == "drop"{
	image_index = floor(timer/5) mod 4 + 4
	var target_pos = get_world_position_from_grid(target_col,target_row)
	y += 15
	if y >= (target_pos.y-15){
		var inst = instance_create_depth(x+15,y-15,-800,obj_coke_bomb_explode)
		inst.sprite_index = spr_curry_lobster_cannon_bullet_effect
		if sprite_index == spr_curry_lobster_cannon_bullet_1{
			inst.sprite_index = spr_curry_lobster_cannon_bullet_effect_1
		}
		if sprite_index == spr_curry_lobster_cannon_bullet_2{
			inst.sprite_index = spr_curry_lobster_cannon_bullet_effect_2
		}
		if sprite_index == spr_lobster_athena_bullet{
			inst.sprite_index = spr_lobster_athena_bullet
		}
		audio_play_sound(snd_lobster_cannon,0,0)
		instance_destroy()
	}
	
	if !instance_exists(target_enemy) || target_enemy == noone{
		target_enemy = find_priority_enemy()
		if target_enemy != noone{
			target_col = target_enemy.grid_col
			target_row = target_enemy.grid_row
			var new_pos = get_world_position_from_grid(target_col,target_row)
			var y_left = abs(y-new_pos.y+15)
			y = new_pos.y-15-y_left
			x = new_pos.x
		}
	}
	else{
		if target_enemy.hp <= 0 || target_enemy.y <= 0{
			target_enemy = find_priority_enemy()
			if target_enemy != noone{
				target_col = target_enemy.grid_col
				target_row = target_enemy.grid_row
				var new_pos = get_world_position_from_grid(target_col,target_row)
				var y_left = abs(y-new_pos.y+15)
				y = new_pos.y-15-y_left
				x = new_pos.x
			}
		}
	}
}