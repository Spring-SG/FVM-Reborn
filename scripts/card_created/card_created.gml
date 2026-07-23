/// @function plant_created(plant_inst, col, row)
/// @description 当植物创建时调用，更新网格数据
/// @param {instance} plant_inst 植物实例
/// @param {real} col 网格列
/// @param {real} row 网格行
function card_created(plant_inst, col, row) {
	
	// 客户端拦截种植，放送种植请求
	if(global.network.mode=="client"&&!global.network.client_able){
		var skill = variable_instance_get(plant_inst, "skill") ?? 0;
		var shape = variable_instance_get(plant_inst, "shape") ?? 0;
		var level = variable_instance_get(plant_inst, "current_level") ?? 0;
		var _meta = package_character(plant_inst);
		var _sid = plant_inst.sprite_index;
	var _sprite_name = ds_map_exists(global._pid_reverse, _sid) ? global._pid_reverse[? _sid] : sprite_get_name(_sid);

		if (plant_inst.object_index == obj_magic_chicken) {
			var _target = variable_instance_get(plant_inst, "target_card") ?? "";
			if _target == ""{
				_meta = {target_card:""}
			}else{
				var target_card_info ={
					skill:get_card_info(_target)[$ "skill"],
					shape:get_card_info(_target)[$ "shape"],
					level:get_card_info(_target)[$ "level"],
					sprite_index: ds_map_exists(global._pid_reverse, global.prev_place_id_shape) ? global._pid_reverse[? global.prev_place_id_shape] : sprite_get_name(global.prev_place_id_shape)
				}
				_meta = {target_card:_target,target_card_info:target_card_info};
			}
		}

		var _plat = get_platform_at_grid(col, row)
		if (_plat != noone) {
		      _plat_id = ds_map_exists(global.network.map_instance_id_net_id, _plat.id) ? global.network.map_instance_id_net_id[? _plat.id] : -1;
			  if(_plat_id!=-1)
			  {
				  _meta[$ "platform_id"]  = _plat_id;
				  _meta[$ "platform_offset"]  = _plat.current_offset;
			  }
		}

		_meta = json_stringify(_meta);
		send_message(global.network.server_socket, MSG_UNIT_REQUEST, level, col, row, skill, shape, object_get_name(plant_inst.object_index), _meta, _sprite_name);
		return;
	}



    // 获取该网格的植物列表
    var plant_list = ds_grid_get(global.grid_plants, col, row);

    // 添加新植物到列表
    ds_list_add(plant_list, plant_inst);

    // 设置植物的网格位置
    plant_inst.grid_col = col;
    plant_inst.grid_row = row;

    // 更新植物的深度偏移（根据层级）
    plant_inst.depth_offset = ds_list_size(plant_list) * 5;

    // 更新所有植物的深度偏移
	sort_plants_in_grid(col, row)

	// 服务端广播种植消息
	if(global.network.mode=="server"){
		var level = variable_instance_get(plant_inst, "current_level") ?? 0;
		var skill = variable_instance_get(plant_inst, "skill") ?? 0;
		var shape = variable_instance_get(plant_inst, "shape") ?? 0;
		var _sid = plant_inst.sprite_index;
		var _sprite_name = ds_map_exists(global._pid_reverse, _sid) ? global._pid_reverse[? _sid] : sprite_get_name(_sid);
		
		var _target = variable_instance_get(plant_inst, "target_card") ?? "";
		var object_name = object_get_name(plant_inst.object_index);

		var _meta = {};

		if (variable_instance_exists(plant_inst, "player") && is_struct(plant_inst.player)) {
			_meta = { player: plant_inst.player };
		} else if (plant_inst.object_index == obj_magic_chicken ) {
			if (variable_instance_exists(plant_inst, "target_card_info")){
				var _tci = plant_inst.target_card_info;
				var _tci_sid = _tci[$ "sprite_index"];
				if (!is_string(_tci_sid)) {
					_tci_sid = ds_map_exists(global._pid_reverse, _tci_sid) ? global._pid_reverse[? _tci_sid] : sprite_get_name(_tci_sid);
				}
				var _tci_copy = {
					skill: _tci[$ "skill"],
					shape: _tci[$ "shape"],
					level: _tci[$ "level"],
					sprite_index: _tci_sid
				};
				_meta = { target_card: plant_inst.target_card, target_card_info: _tci_copy };
			}else if _target!=""{
				var target_card_info ={
					skill:get_card_info(_target)[$ "skill"],
					shape:get_card_info(_target)[$ "shape"],
					level:get_card_info(_target)[$ "level"],
					sprite_index: ds_map_exists(global._pid_reverse, global.prev_place_id_shape) ? global._pid_reverse[? global.prev_place_id_shape] : sprite_get_name(global.prev_place_id_shape)
				}
				_meta = {target_card:_target,target_card_info:target_card_info};
			}else
				_meta = {target_card:""}
		} else {
			_meta = package_character(plant_inst);
		}
		
		
		var _plat = get_platform_at_grid(col, row)
		if (_plat != noone) {
		      _plat_id = ds_map_exists(global.network.map_instance_id_net_id, _plat.id) ? global.network.map_instance_id_net_id[? _plat.id] : -1;
			  if(_plat_id!=-1)
			  {
				  _meta[$ "platform_id"]  = _plat_id;
				  _meta[$ "platform_offset"]  = _plat.current_offset;
			  }
		}
		
		// 同步 sprite_list（转为字符串名）
		if (variable_instance_exists(plant_inst, "sprite_list")) {
		    var _sl = plant_inst.sprite_list;
		    var _sl_names = [];
		    for (var _si = 0; _si < array_length(_sl); _si++) {
		        var _sid = _sl[_si];
		        _sl_names[_si] = ds_map_exists(global._pid_reverse, _sid) ? global._pid_reverse[? _sid] : sprite_get_name(_sid);
		    }
		    _meta[$ "sprite_list"] = _sl_names;
		}

		_meta = json_stringify(_meta);
		var _list = global.network.connected_clients;
		var _size = array_length(_list);
		for (var i = 0; i < _size; i++) {
			var _socket = _list[i];
			send_message(_socket, MSG_SPAWN_UNIT, global.network.net_instance_count, level, col, row, skill, shape, _sprite_name, object_name, _meta);
		}
		add_net_id(plant_inst.id);
	}

}



function package_character(plant_inst){
	if (plant_inst.object_index == obj_player_character) {
		var _eq = {};
		
		var _mw = global.save_data.equipped_items.main_weapon;
		if (_mw.id != "") {
			_eq.main_weapon_id = global.save_data.equipped_items.main_weapon.id;
			var atk =get_weapon_info(_mw.id).atk
			if get_gem_index("attack_gem")!= -1{
				atk = get_weapon_info(_mw.id).atk_impact[get_gem_level("attack_gem")]
			}
			_eq.main_weapon_atk = atk;
		}
		
		var _sw = global.save_data.equipped_items.secondary_weapon;
		if (_sw.id != "") {
			_eq.secondary_weapon_id = global.save_data.equipped_items.secondary_weapon.id;
		}
		var _sup = global.save_data.equipped_items.super_weapon;
		if (_sup.id != "") {
			_eq.super_weapon_id =  global.save_data.equipped_items.super_weapon.id;
		}
		
		
		if get_gem_index("health_gem")!= -1{
			_eq.health_gem_increase = get_gem_info("health_gem").hp_increase * (get_gem_level("health_gem")+1);
		}else{
			_eq.health_gem_increase = 0;
		}

		
		if get_gem_index("power_gem")!= -1{ _eq.power_gem_level = get_gem_level("power_gem"); }
		if get_gem_index("gale_gem")!= -1{ _eq.gale_gem_level = get_gem_level("gale_gem"); }
		if get_gem_index("produce_gem")!= -1{ _eq.produce_gem_level = get_gem_level("produce_gem"); } 
		if get_gem_index("slow_down_gem")!= -1{ _eq.slow_down_gem_level = get_gem_level("slow_down_gem"); }
		if get_gem_index("bleed_gem")!= -1{ _eq.bleed_gem_level = get_gem_level("bleed_gem"); }
		if get_gem_index("guard_gem")!= -1{ _eq.guard_gem_level = get_gem_level("guard_gem"); }
		if get_gem_index("strength_gem")!= -1{ _eq.strength_gem_level = get_gem_level("strength_gem"); }
		if get_gem_index("transform_gem")!= -1{ _eq.transform_gem_level = get_gem_level("transform_gem"); }
			
		
		return { player: _eq };
	}
	return {}
}