if ds_list_find_index(brazier_list,other.id) == -1 && burnt < 2 && col == other.grid_col{
	burnt += 1
	if burnt == 2{
		damage = round(damage * other.atk)
	}
	ds_list_add(brazier_list,other.id)
	audio_play_sound(snd_bullet_burnt,0,0)
}