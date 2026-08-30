// Inherit the parent event
event_inherited();

if global.is_paused{
	exit
}
summon_timer ++
if summon_timer >= 30 * 60{
	instance_create_depth(x-30,y-10,-800,obj_war_god_gear)
	summon_timer = 0
}