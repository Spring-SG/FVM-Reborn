// Inherit the parent event
event_inherited();

if state = ENEMY_STATE.ACTING{
	draw_sprite_ext(spr_flute_mouse_effect,(floor(timer/5) mod 22),x-25,y-95,1.8,1.8,0,c_white,1)
}