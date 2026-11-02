// Inherit the parent event
if damage_type == "normal" && shield_hp > 0{
	global.audio.play(snd_hit2,0,0)
}
event_inherited();

