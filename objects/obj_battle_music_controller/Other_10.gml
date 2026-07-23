/// @description 切换音乐
if battle_music != new_battle_music{
if (audio_exists(battle_music)) audio_stop_sound(battle_music)
battle_music = new_battle_music
}