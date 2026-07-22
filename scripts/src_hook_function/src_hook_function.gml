global._evt_created   = [];
global._evt_destroyed = [];
global._evt_log_enabled = false;
global._destroy_queue = ds_list_create()  
global._server_destroy_queue = []
global._boss_spawn_queue = []
global._boss_client_cleanup = []
global._move_instance_pre_arr = []
global._move_instance_map = ds_map_create()
global._is_in_battle=false;





function instance_log_enable(){
	global._evt_log_enabled = true;
	global._evt_created   = [];
	global._evt_destroyed = [];
}

function instance_log_disable(){
	global._evt_log_enabled = false;
	global._evt_created   = [];
	global._evt_destroyed = [];
}


#macro instance_create_depth_origfunc instance_create_depth
#macro instance_create_depth          instance_create_depth_define

#macro instance_destroy_origfunc      instance_destroy
#macro instance_destroy               instance_destroy_define



function instance_create_depth_define(_x, _y, _depth, _obj) {
	// boss产物：客户端拦截，服务端延迟广播(等属性设完)
	var _is_boss = array_contains(global.boss_spawn_sync_list, _obj);
	if (_is_boss && global.network.mode == "client" && !global.network.client_able) {
		var _inst = instance_create_depth_origfunc(_x, _y, _depth, _obj);
		_inst.visible = false;
		array_push(global._boss_client_cleanup, _inst);
		return _inst;
	}

	var _inst = instance_create_depth_origfunc(_x, _y, _depth, _obj);
	if (_inst >= 0) {
		array_push(global._move_instance_pre_arr, _inst);
	}



	if (_inst >= 0 && _is_boss && global.network.mode == "server") {
		add_net_id(_inst.id);
		array_push(global._boss_spawn_queue, _inst);
		return _inst;
	}

	if (_inst >= 0 && global._evt_log_enabled) {
		array_push(global._evt_created, _inst);
	}
	return _inst;
}


function instance_destroy_define() {
	var _id, _exec;
	switch (argument_count) {
		case 0:  _id = id;  _exec = true;  break;
		case 1:  _id = argument[0];  _exec = true;   break;
		case 2:  _id = argument[0];  _exec = argument[1];  break;
	}
	// 客户端：有 net_id 拦住
	if (global.network.mode == "client" && !global.network.client_able && ds_map_exists(global.network.map_instance_id_net_id, _id)) {
		return;
	}
		if (global.network.mode == "server" && ds_map_exists(global.network.map_instance_id_net_id, _id)) {
			var _net_id = global.network.map_instance_id_net_id[? _id];
			array_push(global._server_destroy_queue, _net_id);
		}
		switch (argument_count) {
			case 0:  return instance_destroy_origfunc();
			case 1:  return instance_destroy_origfunc(argument[0]);
			case 2:  return instance_destroy_origfunc(argument[0], argument[1]);
		}
	}




#macro draw_self_origfunc				draw_self
#macro draw_self						draw_self_define

#macro draw_sprite_origfunc				draw_sprite
#macro draw_sprite						draw_sprite_define

#macro draw_sprite_ext_origfunc			draw_sprite_ext
#macro draw_sprite_ext					draw_sprite_ext_define

#macro draw_sprite_part_origfunc		draw_sprite_part
#macro draw_sprite_part					draw_sprite_part_define

#macro draw_sprite_part_ext_origfunc	draw_sprite_part_ext
#macro draw_sprite_part_ext				draw_sprite_part_ext_define

#macro draw_sprite_stretched_origfunc	draw_sprite_stretched
#macro draw_sprite_stretched			draw_sprite_stretched_define

#macro draw_sprite_stretched_ext_origfunc	draw_sprite_stretched_ext
#macro draw_sprite_stretched_ext			draw_sprite_stretched_ext_define

#macro draw_sprite_general_origfunc		draw_sprite_general
#macro draw_sprite_general				draw_sprite_general_define

#macro draw_sprite_pos_origfunc			draw_sprite_pos
#macro draw_sprite_pos					draw_sprite_pos_define

#macro draw_sprite_tiled_origfunc		draw_sprite_tiled
#macro draw_sprite_tiled				draw_sprite_tiled_define

#macro draw_sprite_tiled_ext_origfunc	draw_sprite_tiled_ext
#macro draw_sprite_tiled_ext			draw_sprite_tiled_ext_define


function __sprite_resolve(_spr){
	if is_string(_spr){
		_spr = get_load_sprite(_spr);
	}
	if (ds_map_exists(global._pid_reverse, _spr)) {
		var _name = global._pid_reverse[? _spr];
		var _real = global._sprite_cache[? _name];
		if(global._is_in_battle && global._sprite_state[? _name]<full_load
			&& !(ds_map_exists(global._pending_map, _name) && global._pending_map[? _name])){
			sprite_manager_load_async([_name]);
		}
		if (!is_undefined(_real)) {
			return _real;
		}
	}
	return _spr;
}

function draw_self_define(){
	var _bak_spr = sprite_index;
	
	if (ds_map_exists(global._pid_reverse, _bak_spr)) {
		var _name = global._pid_reverse[? _bak_spr];
		var _real = global._sprite_cache[? _name];
		if(global._is_in_battle && global._sprite_state[? _name]<full_load
			&& !(ds_map_exists(global._pending_map, _name) && global._pending_map[? _name])){
			sprite_manager_load_async([_name]);
		}
		if (!is_undefined(_real)) {
			sprite_index = _real;
			if(_real==_bak_spr){
				draw_self_origfunc();
				return;
			}
		}
		if(ds_map_exists(global._sprite_cache,_name) &&global._sprite_state[? _name]==full_load){
			var t = global._sprite_state[? _name];
			_bak_spr = _real;
		}
	}
	draw_self_origfunc();
	sprite_index = _bak_spr;
}


function draw_sprite_define(_spr, _subimg, _x, _y){
	draw_sprite_origfunc(__sprite_resolve(_spr), _subimg, _x, _y);
}

function draw_sprite_ext_define(_spr, _subimg, _x, _y, _xscale, _yscale, _rot, _colour, _alpha){
	draw_sprite_ext_origfunc(__sprite_resolve(_spr), _subimg, _x, _y, _xscale, _yscale, _rot, _colour, _alpha);
}

function draw_sprite_part_define(_spr, _subimg, _left, _top, _w, _h, _x, _y){
	draw_sprite_part_origfunc(__sprite_resolve(_spr), _subimg, _left, _top, _w, _h, _x, _y);
}

function draw_sprite_part_ext_define(_spr, _subimg, _left, _top, _w, _h, _x, _y, _xscale, _yscale, _colour, _alpha){
	draw_sprite_part_ext_origfunc(__sprite_resolve(_spr), _subimg, _left, _top, _w, _h, _x, _y, _xscale, _yscale, _colour, _alpha);
}

function draw_sprite_stretched_define(_spr, _subimg, _x, _y, _w, _h){
	draw_sprite_stretched_origfunc(__sprite_resolve(_spr), _subimg, _x, _y, _w, _h);
}

function draw_sprite_stretched_ext_define(_spr, _subimg, _x, _y, _w, _h, _colour, _alpha){
	draw_sprite_stretched_ext_origfunc(__sprite_resolve(_spr), _subimg, _x, _y, _w, _h, _colour, _alpha);
}

function draw_sprite_general_define(_spr, _subimg, _left, _top, _w, _h, _x, _y, _xscale, _yscale, _rot, _c1, _c2, _c3, _c4, _alpha){
	draw_sprite_general_origfunc(__sprite_resolve(_spr), _subimg, _left, _top, _w, _h, _x, _y, _xscale, _yscale, _rot, _c1, _c2, _c3, _c4, _alpha);
}

function draw_sprite_pos_define(_spr, _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha){
	draw_sprite_pos_origfunc(__sprite_resolve(_spr), _subimg, _x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4, _alpha);
}

function draw_sprite_tiled_define(_spr, _subimg, _x, _y){
	draw_sprite_tiled_origfunc(__sprite_resolve(_spr), _subimg, _x, _y);
}

function draw_sprite_tiled_ext_define(_spr, _subimg, _x, _y, _xscale, _yscale, _colour, _alpha){
	draw_sprite_tiled_ext_origfunc(__sprite_resolve(_spr), _subimg, _x, _y, _xscale, _yscale, _colour, _alpha);
}

