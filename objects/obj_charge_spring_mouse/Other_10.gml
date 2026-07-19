// Inherit the parent event
if damage_type == "normal" && shield_hp > 0{
	audio_play_sound(snd_hit2,0,0)
}
event_inherited();