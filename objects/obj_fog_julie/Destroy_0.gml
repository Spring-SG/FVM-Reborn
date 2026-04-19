with obj_battle{
	if boss_count > 1{
		boss_count--
	}
	else{
		boss_count = 0
		if  current_wave == total_wave-1 {
			global.is_paused = true
			global.game_over = true
			var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over)
			inst.sprite_index = spr_win
			audio_play_sound(snd_win,0,0)
		}
		else{
			level_stage = "pre"
			current_wave += 1
			current_subwave = 0
		}
	}
}
global.save_data.unlocked_items.arno_killed = true
if global.save_data.unlocked_items.mario_mouse_killed && global.save_data.player.level < 7{
	global.save_data.player.level = 7
	show_notice("神殿已解锁",60)
}
instance_destroy(hpbar_inst)
if instance_exists(banding_summon_obj){
	instance_destroy(banding_summon_obj)
}