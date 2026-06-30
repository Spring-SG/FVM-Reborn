// ============================================================
// CVAR 系统（控制台变量）
// ============================================================

global.cvars = {};

/// @description 设置一个控制台变量
/// 用法: setcvar <键名> <值>
function sh_setcvar(args) {
    if (array_length(args) < 3) {
        return "[CVAR] 用法: setcvar <键> <值>";
    }
    var _key = args[1];
    var _val = args[2];
    global.cvars[$ _key] = _val;
    return "[CVAR] " + _key + " = " + _val;
}

/// @description 列出所有控制台变量
/// 用法: listcvar
function sh_listcvar(args) {
    var _keys = variable_struct_get_names(global.cvars);
    if (array_length(_keys) == 0) {
        return "[CVAR] 没有变量";
    }
    var _str = "=== CVARS ===\n";
    for (var i = 0; i < array_length(_keys); i++) {
        var _key = _keys[i];
        _str += _key + " = " + string(global.cvars[$ _key]) + "\n";
    }
    return _str;
}

// 可选：获取单个变量的函数（方便脚本内部使用）
function sh_getcvar(args) {
    if (array_length(args) < 2) return "[CVAR] 用法: getcvar <键>";
    var _key = args[1];
    if (!variable_struct_exists(global.cvars, _key)) {
        return "[CVAR] 变量不存在: " + _key;
    }
    return string(global.cvars[$ _key]);
}


// ============================================================
// 植物生成系统（命令行 + 脚本调用）
// ============================================================

/// @description 在指定网格位置生成植物（通用函数）
/// @param {real} col 列索引
/// @param {real} row 行索引
/// @param {asset} plant_obj 植物对象资源
/// @param {struct} [props] 可选，要覆盖的属性键值对
/// @return {instance} 新创建的植物实例，失败返回 -1
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
    
    // 注册到网格系统
    card_created(_plant, col, row);
	
    
    // 应用自定义属性
    if (is_struct(props)) {
        var _keys = variable_struct_get_names(props);
        for (var i = 0; i < array_length(_keys); i++) {
            var _key = _keys[i];
            _plant[$ _key] = props[$ _key];
        }
    }
    
    // 放置特效（注意：如果不需要特效可跳过）
    if (instance_exists(obj_place_effect)) {
        instance_create_depth(_grid_pos.x, _grid_pos.y, -2, obj_place_effect);
        audio_play_sound(snd_place1, 0, 0);
    }
    


	if _plant.object_index == obj_player_character{
		if not _plant.is_placed{
			/*
			var logical_x = mouse_x;
			var logical_y = mouse_y;
			var platform_shift_x = 0;
			var platform_shift_y = 0;
			var plat = instance_position(mouse_x, mouse_y, obj_platform);
			if (plat != noone) {
				platform_shift_x = plat.visual_x_shift;
				platform_shift_y = plat.visual_y_shift;
				logical_x -= platform_shift_x;
				logical_y -= platform_shift_y;
			}
			
			var can_plant = (can_place_at_position(logical_x, logical_y, "normal","amphi","none"));
			if can_plant{
			*/

			
			if true{
				_plant.is_placed = true
				/*
				global.is_paused = false
				var grid_pos = get_grid_position_from_world(logical_x, logical_y)
				x = grid_pos.x + platform_shift_x
				y = grid_pos.y+10 + platform_shift_y
				grid_row = grid_pos.row
				grid_col = grid_pos.col
				*/
				
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
				var gem_index = 0
				if global.save_data.equipped_items.main_weapon.id != ""{
					var main_info = get_weapon_info(global.save_data.equipped_items.main_weapon.id)
					var main_weapon_inst = instance_create_depth(_plant.x-10,_plant.y-100,_plant.depth-1,main_info.obj)
					main_weapon_inst.parent_player = _plant.id
					main_weapon_inst.grid_row = grid_row
					main_weapon_inst.grid_col = grid_col
					_plant.cycle = main_info.cycle
					var gem_list = global.save_data.equipped_items.main_weapon.gems
					for(var i = 0 ; i < array_length(gem_list);i++){
						var gem_id = gem_list[i]
						var gem_info = get_gem_info(gem_id)
						if gem_info.obj != noone{
							instance_create_depth(390,213+gem_index*80,-500,gem_info.obj)
							gem_index++
						}
					}
				}
				if global.save_data.equipped_items.secondary_weapon.id != ""{
					var s_inst = instance_create_depth(_plant.x,_plant.y,_plant.depth,obj_player_shield)
					s_inst.parent_player = _plant.id
					s_inst.grid_row = grid_row
					s_inst.grid_col = grid_col
					var main_info = get_weapon_info(global.save_data.equipped_items.secondary_weapon.id)
					_plant.hp += main_info.hp_increase
					_plant.max_hp += main_info.hp_increase
					if get_gem_index("health_gem") != -1{
						_plant.hp += get_gem_info("health_gem").hp_increase * (get_gem_level("health_gem")+1)
						_plant.max_hp += get_gem_info("health_gem").hp_increase * (get_gem_level("health_gem")+1)
					}
				}
				if global.save_data.equipped_items.super_weapon.id != ""{
					var main_info = get_weapon_info(global.save_data.equipped_items.super_weapon.id)
					var main_weapon_inst = instance_create_depth(_plant.x-10,_plant.y-100,_plant.depth-1,main_info.obj)
					main_weapon_inst.parent_player = _plant.id
					main_weapon_inst.grid_row = grid_row
					main_weapon_inst.grid_col = grid_col
					}
				}
		}
	}
    return _plant;
}

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