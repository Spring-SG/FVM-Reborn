if not disabled{
	var task_id = obj_task_bg.current_task_list[obj_task_bg.target_task_index].id
	var task_info = get_task_data(task_id)
	var reward_list = task_info.rewards
	for(var i = 0 ; i < array_length(reward_list) ; i++){
		if reward_list[i].type == "item"{
			add_material_amount(reward_list[i].item_id,reward_list[i].amount)
		}
		else if reward_list[i].type == "gold"{
			global.save_data.player.gold += reward_list[i].amount
		}
	}
	if !is_task_unlocked(task_info.task_unlock){
		unlock_task(task_info.task_unlock)
	}
	edit_task_state(task_id,"claimed")
	with obj_task_bg{
		refresh_task_list()
	}
	audio_play_sound(snd_button,0,0)
	show_notice("奖励已领取",60)
}