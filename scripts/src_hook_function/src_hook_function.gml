global._evt_created   = [];
global._evt_destroyed = [];
global._evt_log_enabled = false;
global._destroy_queue = ds_list_create()  
global._boss_spawn_queue = []
global._boss_client_cleanup = []
global._move_instance_pre_arr = []
global._move_instance_map = ds_map_create()



// 属性白名单
global._sync_keys = [
	"target_col", "target_row", "grid_col", "grid_row",
	"col", "row", "is_hole",
	"image_index", "image_alpha", "image_speed",
	"start_col", "start_row", "width", "length",
	"move_distance", "move_direction", "move_axis",
	"boundary_idle_duration", "move_speed",
	"initial_offset", "initial_idle_duration","sprite_index",
	"cvspeed", "center_x", "center_y",
	"state", "timer", "skill_timer", "jump_times",
	"skill_choose", "skill_change_style", "move_time", "is_reversed",
	"max_time", "interval", "col", "row", "dir", "type", "is_parent"
];
	
// boss产物白名单
global.boss_spawn_sync_list = ds_list_create();
ds_list_add(global.boss_spawn_sync_list,
	obj_angelababy_summon, obj_angelababy_star, obj_angelababy_target, obj_angelababy_diamond,
	obj_paul_bullet, obj_paul_bullet_effect, obj_blonde_mary_bullet,obj_mario_pipeline, obj_pink_paul_tentacle_drop,
	obj_pete_spike, obj_pete_claw, obj_pete_claw_effect, obj_pete_missile,
	obj_pharaoh_bandage, obj_pharaoh_coffin, obj_pharaoh_hole,
	obj_messenger_ignis_fatuus, obj_messenger_poop, obj_messenger_mace,
	obj_fog, obj_julie_missile, obj_mouse_train_1_bullet, obj_machine_iron_pan_mouse, obj_xiaoming_text, obj_coke_bomb_explode, obj_vajra_lava_effect,obj_vajra_lava, obj_vajra_spike, obj_vajra_lightning,
	obj_buzz_wind,obj_paratrooper_mouse,obj_irritable_jack_fire_mouse,obj_irritable_jack_fire, obj_irritable_jack_rock_skill_3, obj_irritable_jack_rock_skill_4,
	obj_baron_needle, obj_baron_bats, obj_baron_blade, obj_rumble_missile, obj_rumble_laser, obj_ice_residue_ball, obj_ice_residue_bullet,
	obj_arno_bullet, obj_arno_bullet_effect, obj_engineer_bullet_effect,
	obj_card_inhale_effect, obj_card_heal_effect,
	obj_huge_wave_text,obj_barrier,obj_paratrooper_mouse_shield,obj_lava_burn_effect,
	obj_ladder,obj_lava,obj_ghost_mouse,obj_in_water_effect, obj_mummy_mouse, obj_apple_football_fan_mouse,
	obj_mouse_train_1_body 
	//obj_wine_bottle_bomb_explode
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
	array_push(global._move_instance_pre_arr,_inst);



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
		if (!is_undefined(_real)) {
			return _real;
		}
	}
	return _spr;
}

function draw_self_define(){
	var _bak_spr = sprite_index;
	var _bak_img = image_index;
	if (ds_map_exists(global._pid_reverse, _bak_spr)) {
		var _name = global._pid_reverse[? _bak_spr];
		var _strips_info = global._sprite_strips[? _name];
		if (!is_undefined(_strips_info)) {
			// 多段条带：根据 image_index 切到正确段和子帧
			var _fps = _strips_info.fps;
			var _arr = _strips_info.sprites;
			var _si = floor(image_index) div _fps;
			var _sub = floor(image_index) mod _fps;
			sprite_index = _arr[clamp(_si, 0, array_length(_arr) - 1)];
			image_index = _sub;
		} else {
			var _real = global._sprite_cache[? _name];
			if (!is_undefined(_real)) {
				sprite_index = _real;
			}
		}
	}
	draw_self_origfunc();
	sprite_index = _bak_spr;
	image_index = _bak_img;
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

