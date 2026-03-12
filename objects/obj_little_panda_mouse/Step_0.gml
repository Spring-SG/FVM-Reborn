// Inherit the parent event
if hp <= 0 && state != ENEMY_STATE.DEAD{
	sprite_index = spr_little_panda
	state = ENEMY_STATE.DEAD
	timer = 0
}

event_inherited();

var target_pos = get_world_position_from_grid(target_col,target_row)

if state = ENEMY_STATE.ACTING{
	if grid_col > target_col && y < target_pos.y+38{
		x += chspeed
		y -= cvspeed
		cvspeed -= cgravity
		image_index = floor(timer/3) mod 9
	}
	else{
		y = target_pos.y+38
		land_timer ++
		image_index = floor(land_timer/flash_speed) mod 3 + 9
		if land_timer >= 3*flash_speed-1{
			sprite_index = spr_little_panda
			state = ENEMY_STATE.NORMAL
			timer = 0
			target_type = "normal"
		}
	}
}