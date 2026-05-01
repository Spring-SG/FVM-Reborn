// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	sprite_index = spr_wrestler_mouse
	state = ENEMY_STATE.DEAD
	timer = 0
}

event_inherited();

if global.is_paused || is_frozen || is_stun || is_scare{
	exit
}

if hp <= maxhp * hurt_rate && state != ENEMY_STATE.ACTING && state != ENEMY_STATE.DEAD && state != ENEMY_STATE.APPEAR && grid_col > 4 && not throwed{
	timer = 0
	sprite_index = spr_wrestler_mouse_throw
	state = ENEMY_STATE.APPEAR
	throwed = true
}

if state == ENEMY_STATE.ATTACK{
	state = ENEMY_STATE.ACTING
	timer = 0
}



var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
}

if state == ENEMY_STATE.ACTING{
	if (hp/maxhp  > hurt_rate) {
		image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2);
	} else {
		image_index = (floor(timer / flash_speed) mod attack_anim + move_anim * 2 + attack_anim);
	}
	if timer == 10 * flash_speed{
		if instance_exists(target_plant){
			with target_plant{
				if !invincible{
					hp -= 900
					event_user(2)
				}
			}
		}
	}
	if timer >= attack_anim * flash_speed -1{
		state = ENEMY_STATE.NORMAL
		timer = 0
	}
}

if state == ENEMY_STATE.APPEAR{
	if (hp/maxhp  > hurt_rate) {
		image_index = floor(timer / flash_speed) mod 14;
	} else {
		image_index = floor(timer / flash_speed) mod 14 + 14;
	}
	if timer >= 14 * flash_speed -1{
		state = ENEMY_STATE.NORMAL
		timer = 0
		sprite_index = spr_wrestler_mouse
	}
	if timer == 7 * flash_speed - 1{
		var inst = instance_create_depth(x+35,y-125,depth-1,obj_little_wrestler_mouse)
		inst.target_col = irandom_range(2,3)
		inst.target_row = grid_row
		inst.grid_row = grid_row
		
		// 获取敌人当前位置和速度
		var bullet_pos = get_world_position_from_grid(inst.target_col,grid_row)
		var enemy_x = bullet_pos.x
		var enemy_y = bullet_pos.y+38
    
		// 计算子弹飞行时间（基于水平距离和预设速度）
		var distance_x = enemy_x - inst.x
		var flight_time = clamp(75 + (distance_x/1000) * 45, 75, 120)

		// 计算子弹所需的速度向量
		var total_distance_x = distance_x
		var total_distance_y = 600//enemy_y - inst.y
    
		// 抛物线运动参数计算:cite[6]
		inst.chspeed = total_distance_x / flight_time
		inst.cgravity = (2 * total_distance_y) / (flight_time * flight_time)
		inst.cvspeed = (total_distance_y - 0.05 * inst.cgravity * flight_time * flight_time) / flight_time
	}
}