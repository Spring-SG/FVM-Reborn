

function spawn_plant(col, row, plant_obj, props) {
    // 边界检查
    if (col < 0 || col >= global.grid_cols || row < 0 || row >= global.grid_rows) {
        show_debug_message("[spawn_plant] 无效网格位置 (" + string(col) + ", " + string(row) + ")");
        return -1;
    }
    
    // 计算世界坐标
    var _world_x = global.grid_offset_x + col * global.grid_cell_size_x;
    var _world_y = global.grid_offset_y + row * global.grid_cell_size_y;
    var _grid_pos = get_grid_position_from_world(_world_x, _world_y);
    
    // 创建实例
    var _plant = instance_create_depth(_grid_pos.x, _grid_pos.y, 0, plant_obj);
    if (_plant < 0) {
        show_debug_message("[spawn_plant] 实例创建失败");
        return -1;
    }
    
    // 计算深度
    var _depth = calculate_plant_depth(col, row, _plant.plant_type);
    _plant.depth = _depth;
    
    // 
    
    // 应用自定义属性
    if (is_struct(props)) {
        var _keys = variable_struct_get_names(props);
        for (var i = 0; i < array_length(_keys); i++) {
            var _key = _keys[i];
            _plant[$ _key] = props[$ _key];
        }
    }
	
	card_created(_plant, col, row);
    
    // 放置特效（注意：如果不需要特效可跳过）
    if (instance_exists(obj_place_effect)) {
        instance_create_depth(_grid_pos.x, _grid_pos.y, -2, obj_place_effect);
        audio_play_sound(snd_place1, 0, 0);
    }
	
	// 种植角色
	if _plant.object_index == obj_player_character{
		if not _plant.is_placed{
			if true{
				_plant.is_placed = true

				_plant.x = global.grid_offset_x + col * global.grid_cell_size_x + global.grid_cell_size_x / 2 ;
				_plant.y = global.grid_offset_y + row * global.grid_cell_size_y + global.grid_cell_size_y / 2 + 10;
				var plat = instance_position(_plant.x, _plant.y, obj_platform);
				if (plat != noone) {
					_plant.x = _plant.x + plat.visual_x_shift;
					_plant.y = _plant.y + plat.visual_y_shift;
				}
				
				grid_row =row;
				grid_col =col;
				_plant.grid_row =row;
				_plant.grid_col =col;
				card_created(_plant.id,grid_col,grid_row)
				audio_play_sound(snd_place1,0,0)
				instance_create_depth(_plant.x,_plant.y,-2,obj_place_effect)
				var plany_list = ds_grid_get(global.grid_plants,grid_col,grid_row)
				if global.grid_terrains[grid_row][grid_col].type == "water"{
					var card = instance_create_depth(_plant.x,_plant.y-10,_plant.depth+1,obj_wooden_plate)
					card_created(card,grid_col,grid_row)
			
				}
				

			  var _eq = props[$ "player"];
			  if (!is_undefined(_eq)) {
					var _mw_name_id = _eq[$ "main_weapon_id"] ?? "";
					if (_mw_name_id != "") {
						var main_info = get_weapon_info(_mw_name_id) 
						var main_weapon_inst = instance_create_depth(_plant.x-10, _plant.y-100, _plant.depth-1, main_info.obj);
						main_weapon_inst.parent_player = _plant.id; 
						main_weapon_inst.grid_row = grid_row; 
						main_weapon_inst.grid_col = grid_col;
						_plant.cycle =  main_info.cycle;
						main_weapon_inst.atk =  _eq[$ "main_weapon_atk"];
						
						
						var gem_level = _eq[$ "power_gem_level"] ?? -1;
						if (gem_level >= 0) {
						    main_weapon_inst.atk = get_weapon_info(_mw_name_id).atk_impact[gem_level];
						}

						gem_level = _eq[$ "gale_gem_level"] ?? -1;
						if (gem_level >= 0) {
						     var _wi = get_weapon_info(_mw_name_id);
						     if (variable_struct_exists(_wi, "cycle_impact"))  {
						          main_weapon_inst.cycle = _wi.cycle_impact[gem_level];
						     }
						}
					}
		
					var _sw_name_id = _eq[$ "secondary_weapon"] ?? "";
					if (_sw_name_id != "") {
						var s_inst = instance_create_depth(_plant.x,_plant.y,_plant.depth,obj_player_shield)
						s_inst.parent_player = _plant.id
						s_inst.grid_row = grid_row
						s_inst.grid_col = grid_col
						var main_info = get_weapon_info(_sw_name_id)
						_plant.hp += main_info.hp_increase
						_plant.max_hp += main_info.hp_increase
						
						_plant.hp += _eq[$ "health_gem_increase"]
						_plant.max_hp += _eq[$ "health_gem_increase"]
						
						var gem_level = _eq[$ "produce_gem_level"] ?? -1;
						if (gem_level >= 0) {
							var gem_info = get_gem_info("produce_gem")
							s_inst.cycle = gem_info.cycle[gem_level] * 60
							s_inst.flame_produce = gem_info.flame_value[gem_level]
							s_inst.first_produce_delay = gem_info.first_produce_delay * 60
							s_inst.first_produce =produce_gem_level
							s_inst.produce_gem = true
						}

						gem_level = _eq[$ "slow_down_gem_level"] ?? -1;
						if (gem_level >= 0) {
							s_inst.slow_down_gem = true;
							var gem_info = get_gem_info("slow_down_gem");
							if gem_level > 10 gem_level = 10;
							s_inst.slow_down_cycle = gem_info.cooldown[gem_level] * 60;
						}
						
						gem_level = _eq[$ "bleed_gem_level"] ?? -1;
						if (gem_level >= 0) {
							s_inst.bleed_gem = true;
							var gem_info = get_gem_info("bleed_gem");
							if gem_level > 10 gem_level = 10;
							s_inst.bleed_damage = gem_info.atk[gem_level];
						}
						
						gem_level = _eq[$ "guard_gem_level"] ?? -1;
						if (gem_level >= 0) {
							s_inst.guard_gem = true;
							var gem_info = get_gem_info("guard_gem");
							if gem_level > 10 gem_level = 10;
							s_inst.max_hp_increase = gem_info.max_hp_increase[gem_level];
						}
						
						gem_level = _eq[$ "strength_gem_level"] ?? -1;
						if (gem_level >= 0) {
							s_inst.strength_gem = true;
							var gem_info = get_gem_info("strength_gem");
							if gem_level > 10 gem_level = 10;
							s_inst.atk_ratio = gem_info.atk_ratio[gem_level];
						}
					}
		
					var _sup_name_id = _eq[$ "super_weapon_id"] ?? "";
					if (_sup_name_id != "") {
						var main_info = get_weapon_info(_sup_name_id);
						var main_weapon_inst = instance_create_depth(_plant.x-10,_plant.y-100,_plant.depth-1,main_info.obj)
						main_weapon_inst.parent_player = _plant.id
						main_weapon_inst.grid_row = grid_row
						main_weapon_inst.grid_col = grid_col
					}
					
				}
					
			  }

		}
	}
    return _plant;
}

/*

/// @description 命令行：生成植物
/// 用法: spawn <列> <行> <植物对象名> [属性=值...]
/// 示例: spawn 2 3 obj_small_fire
///       spawn 2 3 obj_xiao_long_bao atk=90 ice_timer=600
function sh_spawn(args) {
    if (array_length(args) < 4) {
        return "[spawn] 用法: spawn <列> <行> <植物对象名> [属性=值...]";
    }
    
    var _col_str = args[1];
    var _row_str = args[2];
    var _obj_name = args[3];
    var _plant_obj = asset_get_index(_obj_name);
    
    if (_plant_obj < 0) {
        return "[spawn] 错误: 对象 '" + _obj_name + "' 不存在";
    }
    
    // 解析自定义属性 (key=value)
    var _props = {};
    for (var i = 4; i < array_length(args); i++) {
        var _pair = args[i];
        var _eq_pos = string_pos("=", _pair);
        if (_eq_pos > 0) {
            var _key = string_copy(_pair, 1, _eq_pos - 1);
            var _val = string_copy(_pair, _eq_pos + 1, string_length(_pair) - _eq_pos);
            _props[$ _key] = _val;
        }
    }
    
    // ---- 处理列通配符 ----
    var _cols = [];
    if (_col_str == "*") {
        for (var c = 0; c < global.grid_cols; c++) {
            array_push(_cols, c);
        }
    } else {
        var _col = real(_col_str);
        if (_col < 0 || _col >= global.grid_cols) {
            return "[spawn] 错误: 列 " + string(_col) + " 超出范围 (0-" + string(global.grid_cols-1) + ")";
        }
        array_push(_cols, _col);
    }
    
    // ---- 处理行通配符 ----
    var _rows = [];
    if (_row_str == "*") {
        for (var r = 0; r < global.grid_rows; r++) {
            array_push(_rows, r);
        }
    } else {
        var _row = real(_row_str);
        if (_row < 0 || _row >= global.grid_rows) {
            return "[spawn] 错误: 行 " + string(_row) + " 超出范围 (0-" + string(global.grid_rows-1) + ")";
        }
        array_push(_rows, _row);
    }
    
    // ---- 循环生成 ----
    var _count = 0;
    for (var i = 0; i < array_length(_cols); i++) {
        for (var j = 0; j < array_length(_rows); j++) {
            var _col = _cols[i];
            var _row = _rows[j];
            var _plant = spawn_plant(_col, _row, _plant_obj, _props);
            if (_plant >= 0) {
                _count++;
            }
        }
    }
    
    if (_count == 0) {
        return "[spawn] 错误: 没有成功生成任何植物";
    }
    
    return "[spawn] 成功生成 " + string(_count) + " 个 " + _obj_name;
}

/// @description rt-shell 元数据：spawn
/// @description 命令行：伪造游戏结束，测试客户端接收
function sh_win(args) {
    if (global.network.mode == "server") {
        var _cl = global.network.connected_clients;
        for (var i = 0; i < array_length(_cl); i++) {
            send_message(_cl[i], MSG_GAME_OVER, 1);
            show_debug_message("[WIN DEBUG] sent to " + string(_cl[i]));
        }
        return "[WIN] sent to " + string(array_length(_cl)) + " clients";
    }
    if (global.network.mode == "client") {
        send_message(global.network.server_socket, MSG_GAME_OVER, 1);
        return "[WIN] sent to server";
    }
    return "[WIN] no network";
}

function meta_win() {
    return {
        description: "伪造游戏胜利消息，测试客户端是否收到",
        arguments: [],
        suggestions: [],
        hidden: false,
        deferred: false
    };
}

/// @description 命令行：测试主动技能
function sh_skill(args) {
    if (array_length(args) < 2) return "[skill] skill <type> [level]";
    var _type = args[1];
    var _level = (array_length(args) >= 3) ? real(args[2]) : 0;
    var _x = obj_player_character.x;
    var _y = obj_player_character.y;
    network_active_skill(_type, _x, _y, _level);
    if (global.network.mode == "server") {
        network_broadcast_active_skill(_type, _x, _y, _level);
    }
    return "[skill] " + _type + " Lv=" + string(_level);
}

function meta_skill() {
    return {
        description: "主动技能测试: laser_gem bomb_gem freeze_gem cateye_gem [level]",
        arguments: ["type", "level"],
        suggestions: [["laser_gem","bomb_gem","freeze_gem","cateye_gem"], []],
        hidden: false,
        deferred: false
    };
}

function meta_spawn() {
    return {
        description: "在指定网格位置生成植物",
        arguments: ["列", "行", "植物对象名", "属性=值..."],
        suggestions: [
            ["0", "1", "2", "3", "4", "5","*"],
            ["0", "1", "2", "3", "4", "5","*"],
            ["obj_fog_julie", "obj_player_character", "obj_double_water_pipe", "obj_triple_wine_rack"]
        ],
        argumentDescriptions: [
            "网格列索引",
            "网格行索引",
            "植物对象名称",
            "可选属性，如 flame_produce=15000"
        ],
        hidden: false,
        deferred: false
    };
}
*/