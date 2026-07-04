global._evt_created   = [];
global._evt_destroyed = [];
global._evt_log_enabled = false;
global._destroy_queue = ds_list_create()  
global._boss_spawn_queue = []
global._boss_client_cleanup = []

// boss产物白名单
global.boss_spawn_sync_list = ds_list_create();
ds_list_add(global.boss_spawn_sync_list,
	obj_angelababy_summon, obj_angelababy_star, obj_angelababy_target,
	obj_paul_bullet, obj_blonde_mary_bullet,
	obj_pete_spike, obj_pete_claw, obj_pete_missile,
	obj_pharaoh_bandage, obj_pharaoh_coffin, obj_pharaoh_hole,
	obj_messenger_ignis_fatuus, obj_messenger_poop, obj_messenger_mace,
	obj_fog, obj_julie_missile,
	obj_buzz_wind,
	obj_baron_needle, obj_baron_bats, obj_baron_blade,
	obj_arno_bullet_effect, obj_card_inhale_effect, obj_card_heal_effect,
	obj_huge_wave_text
);


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
	var _is_boss = (ds_list_find_index(global.boss_spawn_sync_list, _obj) != -1);
	if (_is_boss && global.network.mode == "client" && !global.network.client_able) {
		var _inst = instance_create_depth_origfunc(_x, _y, _depth, _obj);
		_inst.visible = false;
		array_push(global._boss_client_cleanup, _inst);
		return _inst;
	}

	var _inst = instance_create_depth_origfunc(_x, _y, _depth, _obj);

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
	// 服务端：有 net_id 广播
	if (global.network.mode == "server" && ds_map_exists(global.network.map_instance_id_net_id, _id)) {
		var _list = global.network.connected_clients;
		var _net_id = global.network.map_instance_id_net_id[? _id];
		for (var _i = 0; _i < array_length(_list); _i++) {
			send_message(_list[_i], MSG_DESTROY, _net_id);
		}
	}
	switch (argument_count) {
		case 0:  return instance_destroy_origfunc();
		case 1:  return instance_destroy_origfunc(argument[0]);
		case 2:  return instance_destroy_origfunc(argument[0], argument[1]);
	}
}