// Inherit the parent event

if state == ENEMY_STATE.ATTACK{
	target_type = "normal"
}
else{
	target_type = "dance"
}
if hp <= 0 && state != ENEMY_STATE.DEAD{
	state = ENEMY_STATE.DEAD
	timer = 0
	sprite_index = spr_non_mainstream_mouse
}
event_inherited();



if global.is_paused || is_frozen || is_stun{
	exit
}

if dance_cooldown > 0{
	dance_cooldown --
}

if state = ENEMY_STATE.ACTING{
	image_index = floor(timer/flash_speed) mod 20
	if timer == 20*flash_speed - 1 || hp<=0{
		timer = 0
		sprite_index = spr_non_mainstream_mouse
		state = ENEMY_STATE.NORMAL
		dance_cooldown = 120
		if is_slowdown{
			dance_cooldown = 240
		}
	}
}