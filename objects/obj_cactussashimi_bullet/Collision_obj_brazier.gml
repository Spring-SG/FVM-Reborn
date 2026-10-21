if ds_list_find_index(brazier_list,other.id) == -1 && burnt == 0 && row == other.grid_row{
	burnt += 1
	damage = round(damage * other.atk)
	ds_list_add(brazier_list,other.id)
	global.audio.play(snd_bullet_burnt,0,0)
}