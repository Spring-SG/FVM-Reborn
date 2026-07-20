if (variable_instance_exists(id, "old_terrains") && ds_exists(old_terrains, ds_type_grid)) {
	ds_grid_destroy(old_terrains);
}