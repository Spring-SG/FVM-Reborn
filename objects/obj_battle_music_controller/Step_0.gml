if audio_is_paused(battle_music) and not global.is_paused{
	audio_resume_sound(battle_music)
}
if not audio_is_playing(battle_music) and not global.is_paused{
	audio_play_sound(battle_music,0,0)
}
if audio_is_playing(battle_music) and global.is_paused{
	audio_pause_sound(battle_music)
}

if global.laboretory_room{
	var current_music_volum = audio_group_get_gain(music)
	audio_sound_gain(battle_music,current_music_volum)
}