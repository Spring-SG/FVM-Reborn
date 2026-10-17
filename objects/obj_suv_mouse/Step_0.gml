// Inherit the parent event
if global.is_paused{
	exit
}
if hp <= 0 && state != ENEMY_STATE.DEAD{
	target_type = "normal"
	state = ENEMY_STATE.DEAD
	sprite_index = spr_suv_mouse
	timer = 0
}

event_inherited();

if hp > 0 && state != ENEMY_STATE.DEAD{
	if state == ENEMY_STATE.ACTING{
		target_type = "air"
		anim_timer ++
		if hp > maxhp * hurt_rate{
			image_index = floor(anim_timer/5) mod 28
		}
		else{
			image_index = floor(anim_timer/5) mod 28 + 28
		}
		if anim_timer >= 14 * 5 + 2 && anim_timer <= 26 * 5 + 2{
			x -= 6
		}
		if anim_timer >= 28 * 5 - 1{
			anim_timer = 0
			state = ENEMY_STATE.NORMAL
			sprite_index = spr_suv_mouse
			timer = 1
			target_type = "normal"
		}
	}
}