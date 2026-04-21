function map_object_registry_init(){
	global.map_object_pool = ds_map_create()
}

function register_map_object(map_obj_id,map_obj_data){
	ds_map_add(global.map_object_pool,map_obj_id,map_obj_data)
}

function get_map_object_data(map_obj_id){
	return ds_map_find_value(global.map_object_pool,map_obj_id)
}

function map_object_init(){
	map_object_registry_init()
	register_map_object("obstacle",{"name":"障碍物","_obj":obj_obstacle,"x_offset":0,"y_offset":-35})
	register_map_object("wind_tunnel",{"name":"风洞","_obj":obj_wind_tunnel,"x_offset":5,"y_offset":-35})
	register_map_object("lava",{"name":"岩浆","_obj":obj_lava,"x_offset":0,"y_offset":-35})
}