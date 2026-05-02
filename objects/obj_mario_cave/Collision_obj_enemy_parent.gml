var grid_pos = get_grid_position_from_world(x,y)
if instance_exists(banding_pipeline_obj) && other.grid_row == grid_pos.row && (array_get_index(ignore_list,other.mouse_id) == -1){
	var new_pos = get_grid_position_from_world(banding_pipeline_obj.x,banding_pipeline_obj.y)
	other.x = new_pos.x-50
	other.y = new_pos.y+38
	if other.y < global.grid_offset_y{
		other.y += global.grid_cell_size_y
	}
}