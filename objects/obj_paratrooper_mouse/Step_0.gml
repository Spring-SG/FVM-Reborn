// Inherit the parent event
if global.is_paused{
	exit
}

if (hp <= 0 && state != ENEMY_STATE.DEAD) {
	state = ENEMY_STATE.DEAD
	timer = 0
	sprite_index = spr_paratrooper_mouse
}
if !appear{
	target_col = irandom_range(2,6)
	target_row = irandom_range(0,global.grid_rows-1)
	var target_pos = get_world_position_from_grid(target_col,target_row)
	x = target_pos.x+10
	y = -sprite_height - 10
	image_alpha = 1
	appear = true
}
event_inherited();

var current_move_speed = move_speed
if is_slowdown{
	flash_speed = 12
	current_move_speed = move_speed / 2
}
else{
	flash_speed = 6
	current_move_speed = move_speed
}

var target_y = get_world_position_from_grid(target_col,target_row).y + 33

if hp > 0 && state != ENEMY_STATE.DEAD{
	if state == ENEMY_STATE.APPEAR{
		anim_timer++
		//x -= current_move_speed
		
		if y < target_y{
			y += 5
		}
		else{
			y = target_y
			target_type = "normal"
			state = ENEMY_STATE.ACTING
			anim_timer = 0
			instance_create_depth(x-10,y,depth+1,obj_paratrooper_mouse_shield)
		}
		
		image_index = floor(anim_timer/flash_speed) mod 16
	}
	if state == ENEMY_STATE.ACTING{
		anim_timer++
		image_index = floor(anim_timer/flash_speed) mod 6 + 16
		if anim_timer >= flash_speed * 6 - 1{
			target_type = "normal"
			state = ENEMY_STATE.NORMAL
			timer = 0
			sprite_index = spr_paratrooper_mouse
			
		}
		
	}
}