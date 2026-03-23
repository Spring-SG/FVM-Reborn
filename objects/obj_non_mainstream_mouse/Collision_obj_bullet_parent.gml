if state != ENEMY_STATE.ATTACK && state != ENEMY_STATE.ACTING && dance_cooldown <= 0 && hp > 0{
	timer = 0
	state = ENEMY_STATE.ACTING
	sprite_index = spr_list[irandom_range(0,2)]
}