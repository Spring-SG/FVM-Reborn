global._move_instance_pre_arr = []
global._move_instance_map = ds_map_create()

#macro instance_create_depth_origfunc instance_create_depth
#macro instance_create_depth          instance_create_depth_define


function instance_create_depth_define(_x, _y, _depth, _obj) {

	var _inst = instance_create_depth_origfunc(_x, _y, _depth, _obj);
	array_push(global._move_instance_pre_arr,_inst);

	return _inst;
}