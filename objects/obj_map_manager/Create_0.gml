// 强制清除application_surface，避免上一房间图像残留
surface_set_target(application_surface);
draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
surface_reset_target();
instance_create_depth(100,0,-2,obj_player_info_ui)

/// @type {Asset.GMObject.EventEntranceList} 
var _entrance_list = instance_create_depth(0, 0, -2, EventEntranceList)
_entrance_list.set_position(600,20)
              .set_size(900, 300)

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

instance_create_depth(room_width-210,room_height,-1,obj_player_menu_bg)


