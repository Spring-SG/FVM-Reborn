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
		global.audio.play(snd_lobster_cannon,0,0)
		instance_destroy()
	}
	
	// 重新索敌：当前目标格里已经没有可打的敌人了，就换成当前的最优目标格
	//   只用格子坐标判断，不再持有实例 id —— 目标在同一帧里被别的子弹打死也不会崩
	var _t = find_priority_enemy()
	var _cell_idx = target_row * global.grid_cols + target_col
	var _target_alive = (target_col >= 0 && target_row >= 0
		&& _cell_idx >= 0 && _cell_idx < array_length(global._curry_cannon_alive)
		&& global._curry_cannon_alive[_cell_idx]);
	if (!_target_alive && _t != noone){
		target_col = _t.col
		target_row = _t.row
		var new_pos = get_world_position_from_grid(target_col,target_row)
		var y_left = abs(y-new_pos.y+15)
		y = new_pos.y-15-y_left
		x = new_pos.x
	}
}