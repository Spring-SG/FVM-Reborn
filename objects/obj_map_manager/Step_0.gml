if keyboard_check_pressed(vk_escape){
	if instance_exists(obj_config_menu){
		instance_destroy(obj_config_menu)
		obj_player_info_ui.menu_type = 0
	}
	else if instance_exists(obj_edit_menu){
		instance_destroy(obj_edit_menu)
		obj_player_info_ui.menu_type = 0
	}
	else if instance_exists(obj_world_map_menu){
		instance_destroy(obj_world_map_menu)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_package_bg){
		instance_destroy(obj_package_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_info_island_bg){
		instance_destroy(obj_info_island_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_shop_bg){
		instance_destroy(obj_shop_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_task_bg){
		instance_destroy(obj_task_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_craft_bg){
		instance_destroy(obj_craft_bg)
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
	}
	else if instance_exists(obj_tower_cake_bg){
		obj_player_info_ui.menu_type = 0
		obj_world_map_button.world_map = 0
		global.gui_stack.pop()
	}
	else{
		global.gui_stack.to(room_menu)
	}
}

if current_map_id != global.map_id{
	instance_destroy(obj_levelselect_button)
	current_map_id = global.map_id
	var map_button_array = struct_get(ds_map_find_value(global.maps_map,current_map_id),"levels_data")
	var button_array_length = array_length(map_button_array)
	for(var i = 0 ; i <button_array_length ; i++){
		var button_struct = map_button_array[i]
		var inst = instance_create_depth(button_struct.button_x,button_struct.button_y,-2,obj_levelselect_button)
		inst.image_index = button_struct.button_index
		inst.target_level_id = button_struct.id
		inst.target_level_file_hard = button_struct.hard_level_file
		inst.target_level_file = button_struct.level_file
		inst.level_index = i
		inst.player_level_require = button_struct.player_level_require
		inst.pre_level_require = button_struct.pre_level_require
		inst.sprite_index = button_struct.button_spr
	}
}