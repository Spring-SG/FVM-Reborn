// Inherit the parent event

if global.is_paused{
	exit
}
if (hp <= 0) {
	sprite_index = spr_magician_mouse
	if state != ENEMY_STATE.DEAD{
	    timer = 0;
	    state = ENEMY_STATE.DEAD;
	}
    target_plant = noone;  // 清除攻击目标
}

event_inherited();

if is_frozen || is_stun{
	exit
}



var current_cycle = 0
var current_move_speed = 0
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
	current_cycle = cycle*2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
	current_cycle = cycle
}

if state == ENEMY_STATE.APPEAR{
	if hp > 0{
		anim_timer++
		x -= current_move_speed
		image_index = floor(anim_timer/flash_speed) mod 6
		if x <= get_world_position_from_grid(9,grid_row).x{
			anim_timer = 0
			sprite_index = spr_magician_mouse
			state = ENEMY_STATE.ACTING
		}
	}
}

if state == ENEMY_STATE.ACTING{
	
	attack_timer++
	if attack_timer < current_cycle - flash_speed * attack_anim{
		if (hp/maxhp > hurt_rate) {
			image_index = floor(timer / flash_speed) mod move_anim;
		} else {
			image_index = (floor(timer / flash_speed) mod move_anim) + move_anim;
		}
	}
	else if attack_timer < current_cycle{
		anim_timer++
		if (hp/maxhp > hurt_rate) {
			image_index = floor(anim_timer / flash_speed) mod attack_anim + move_anim * 2; 
		} else {
			image_index = (floor(anim_timer / flash_speed) mod attack_anim) + move_anim * 2 + attack_anim;
		}
		if attack_timer == current_cycle - flash_speed * 17{
			var inst = instance_create_depth(x+35,y-125,depth-1,obj_little_magician_mouse)
			inst.target_col = irandom_range(4,6)
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
	else{
		attack_timer = 0
		anim_timer = 0
	}
}