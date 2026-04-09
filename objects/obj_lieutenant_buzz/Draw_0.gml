// Inherit the parent event
event_inherited();

if state == BOSS_STATE.SKILL2 && skill_timer <= 90 && jump_times < 3{
	draw_sprite_ext(spr_apple_football_fan_mouse_helmet,0,x+40,y,1.8,1.8,0,c_white,1)
}