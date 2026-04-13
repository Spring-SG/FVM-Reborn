current_wave_hp = 0
with obj_enemy_parent{
	if target_type != "obstacle"{
		other.current_wave_hp += hp
	}
}
var c_min_time = wave_min_time
if is_real(global.level_file.version){
	if global.level_file.version >= 1.3{
		if global.level_file.waves[current_wave].subwaves[current_subwave].local_min_wave_time >0{
			c_min_time = global.level_file.waves[current_wave].subwaves[current_subwave].local_min_wave_time
		}
	}
}
if current_wave_hp <= hp_ratio * current_total_hp && level_stage != "boss"{
	if wave_timer < wave_max_time - c_min_time && wave_timer > 30{
		wave_timer = 30
	}
}
if not global.is_paused{
	wave_timer --
}
if (!global.save_data.unlocked_items.elite_unlocked && current_wave >= global.level_file.elite_wave)||current_wave >= global.level_file.total_waves{
	if current_wave_hp <= 0 && !instance_exists(obj_game_over){
		global.is_paused = true
		global.game_over = true
		var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
		inst.sprite_index = spr_win
		audio_play_sound(snd_win,0,0)
	}
}