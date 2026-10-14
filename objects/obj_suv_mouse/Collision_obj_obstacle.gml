if state != ENEMY_STATE.ACTING && grid_row == other.row && hp > 0 && state != ENEMY_STATE.DEAD && x >= other.x{
	state = ENEMY_STATE.ACTING
	sprite_index = spr_suv_mouse_act
	anim_timer = 0
}