instance_destroy(obj_closetask_btn)
instance_destroy(obj_task_claim_btn)
instance_destroy(obj_task_line_bg)
instance_destroy(obj_task_select_btn)
var remove_task_id_list = []
for(var i = 0 ; i < array_length(global.save_data.tasks);i++){
	if global.save_data.tasks[i].state == "claimed"{
		array_push(remove_task_id_list,global.save_data.tasks[i].id)
	}
}
for(var i = 0 ; i < array_length(remove_task_id_list);i++){
	remove_task(remove_task_id_list[i],1)
}
obj_player_info_ui.menu_type = 0
obj_world_map_button.world_map = 0

panel_anim_free(id)
