/// @function network_shovel_remove(col, row, net_id, flame_rate)
/// @param {real} col          网格列
/// @param {real} row          网格行
/// @param {real} net_id       植物网络ID，-1表示无植物
/// @param {real} flame_rate   回收火苗比例
/// @description 执行铲除操作：查找植物、播放动画、返还火苗、销毁植物
function network_shovel_remove(col, row, net_id, flame_rate) {
    var target_plant = noone;

    // 1. 优先通过网络ID查找植物
    if (net_id != -1 && ds_map_exists(global.network.map_net_id_instance_id, net_id)) {
        target_plant = global.network.map_net_id_instance_id[? net_id];
        if (!instance_exists(target_plant)) {
            target_plant = noone;
        }
    }

    // 2. 回退：通过网格位置查找
    if (target_plant == noone) {
        var plant_list = ds_grid_get(global.grid_plants, col, row);
        for (var i = 0; i < ds_list_size(global.shovel_order); i++) {
            var target_type = ds_list_find_value(global.shovel_order, i);
            for (var j = ds_list_size(plant_list) - 1; j >= 0; j--) {
                var plant = ds_list_find_value(plant_list, j);
                if (plant.plant_type == target_type && plant.can_shovel_remove) {
                    target_plant = plant;
                    break;
                }
            }
            if (target_plant != noone) break;
        }
    }

    // 3. 获取本地铲子精灵
    var shovel_spr_to_use = spr_shovel;
    if (instance_exists(obj_shovel_slot)) {
        shovel_spr_to_use = obj_shovel_slot.shovel_spr;
    }

    var logical_world = get_world_position_from_grid(col, row);

    if (target_plant != noone) {
        // 找到植物：执行铲除
        with (target_plant) {
            var shovel_effect = instance_create_depth(x+10, y-55, depth, obj_shovel);
            shovel_effect.sprite_index = shovel_spr_to_use;

            // 返还火苗
            if (flame_rate > 0) {
                var flame_cost = get_plant_data_with_skill(plant_id, shape, current_level, skill)[? "cost"];
                var flame_inst = instance_create_depth(x, y-30, -2000, obj_flame);
                flame_inst.value = round(flame_cost * flame_rate);
            }

            // 地形特效和音效
            if (global.grid_terrains[row][col].type == "normal") {
                instance_create_depth(logical_world.x, logical_world.y, -2, obj_place_effect);
                audio_play_sound(snd_place2, 1, false);
            } else if (global.grid_terrains[row][col].type == "water") {
                var inst = instance_create_depth(logical_world.x, logical_world.y+20, -2500, obj_place_effect);
                inst.sprite_index = spr_enter_water_effect;
                audio_play_sound(snd_enter_water, 0, 0);
            }

            instance_destroy();
        }
        sort_plants_in_grid(col, row);
    } else {
        // 没找到植物：空铲动画
        var shovel_effect = instance_create_depth(logical_world.x, logical_world.y-55, depth, obj_shovel);
        shovel_effect.sprite_index = shovel_spr_to_use;

        if (global.grid_terrains[row][col].type == "normal") {
            instance_create_depth(logical_world.x, logical_world.y, -2, obj_place_effect);
            audio_play_sound(snd_place2, 1, false);
        } else if (global.grid_terrains[row][col].type == "water") {
            var inst = instance_create_depth(logical_world.x, logical_world.y+20, -2500, obj_place_effect);
            inst.sprite_index = spr_enter_water_effect;
            audio_play_sound(snd_enter_water, 0, 0);
        }
    }
}


/// @function network_broadcast_shovel_remove(col, row, net_id, flame_rate)
/// @param {real} col          网格列
/// @param {real} row          网格行
/// @param {real} net_id       植物网络ID，-1表示无植物
/// @param {real} flame_rate   回收火苗比例
/// @description 服务端广播铲除操作给所有客户端
function network_broadcast_shovel_remove(col, row, net_id, flame_rate) {
    if (global.network.mode != "server") return;

    var _list = global.network.connected_clients;
    var _size = array_length(_list);
    for (var _i = 0; _i < _size; _i++) {
        var _socket = _list[_i];
        send_message(_socket, MSG_REMOVE_UNIT, net_id, col, row, flame_rate);
    }
}


/// @function network_enemy_steal(col, row, net_id)
/// @param {real} col          网格列
/// @param {real} row          网格行
/// @param {real} net_id       植物网络ID
/// @description 执行蝙蝠鼠偷取植物：查找植物、播放偷取特效、销毁植物
function network_enemy_steal(col, row, net_id) {
    var target_plant = noone;

    // 1. 优先通过网络ID查找
    if (net_id != -1 && ds_map_exists(global.network.map_net_id_instance_id, net_id)) {
        target_plant = global.network.map_net_id_instance_id[? net_id];
        if (!instance_exists(target_plant)) { target_plant = noone; }
    }

    // 2. 回退：通过网格位置查找
    if (target_plant == noone) {
        var plant_list = ds_grid_get(global.grid_plants, col, row);
        for (var i = 0; i < ds_list_size(global.shovel_order); i++) {
            var target_type = ds_list_find_value(global.shovel_order, i);
            for (var j = ds_list_size(plant_list) - 1; j >= 0; j--) {
                var plant = ds_list_find_value(plant_list, j);
                if (plant.plant_type == target_type && plant.can_shovel_remove && plant.plant_id != "player") {
                    target_plant = plant;
                    break;
                }
            }
            if (target_plant != noone) break;
        }
    }

    // 3. 执行偷取
    if (target_plant != noone) {
        with (target_plant) {
            var inst = instance_create_depth(x, y, depth+1, obj_card_stolen);
            inst.sprite_index = sprite_index;
            inst.image_index = image_index;
            instance_destroy();
        }
    }
}


/// @function network_broadcast_enemy_steal(col, row, net_id)
/// @param {real} col          网格列
/// @param {real} row          网格行
/// @param {real} net_id       植物网络ID
/// @description 服务端广播蝙蝠鼠偷取给所有客户端
function network_broadcast_enemy_steal(col, row, net_id) {
    if (global.network.mode != "server") return;
    var _list = global.network.connected_clients;
    var _size = array_length(_list);
    for (var _i = 0; _i < _size; _i++) {
        var _socket = _list[_i];
        send_message(_socket, MSG_ENEMY_STEAL, net_id, col, row);
    }
}


/// @function network_apply_plant_level(_plant, level, skill, shape)
/// @param {instance} _plant   植物实例
/// @param {real} level        星级
/// @param {real} skill        技能分支
/// @param {real} shape        形态
/// @description 用网络同步的星级/技能/形态重新初始化植物属性，覆盖本地存档
function network_apply_plant_level(_plant, level, skill, shape) {
    // 1. 清理本地存档创建的星标
    if (variable_instance_exists(_plant, "banding_star_obj")) {
        if (instance_exists(_plant.banding_star_obj)) {
            instance_destroy(_plant.banding_star_obj);
            _plant.banding_star_obj = noone;
        }
    }

    // 2. 设置网络值
    _plant.current_level = level;
    _plant.skill = skill;
    _plant.shape = shape;

    // 3. 重新计算属性
    var upgrade_data = get_plant_data_with_skill(_plant.plant_id, shape, level, skill);
    if (upgrade_data != undefined) {
        _plant.hp = upgrade_data[? "hp"];
        _plant.max_hp = _plant.hp;
        _plant.atk = upgrade_data[? "atk"];
        _plant.range = upgrade_data[? "range"];
        _plant.cooldown = upgrade_data[? "cooldown"];
        _plant.cycle = upgrade_data[? "cycle"];
        if (ds_map_exists(upgrade_data, "flame_produce")) {
            _plant.flame_produce = upgrade_data[? "flame_produce"];
        }
    }

    // 4. 创建正确星级的星标
    if (level >= 4) {
        var star_spr = -1;
        switch (level) {
            case 4: star_spr = spr_star_4; break;
            case 5: star_spr = spr_star_5; break;
            case 6: star_spr = spr_star_6; break;
            case 7: star_spr = spr_star_7; break;
            case 8: star_spr = spr_star_8; break;
            case 9: star_spr = spr_star_9; break;
            case 10: star_spr = spr_star_10; break;
            case 11: star_spr = spr_star_11; break;
            case 12: star_spr = spr_star_12; break;
            case 13: star_spr = spr_star_13; break;
            case 14: star_spr = spr_star_14; break;
            case 15: star_spr = spr_star_15; break;
            case 16: star_spr = spr_star_16; break;
        }
        var inst = instance_create_depth(_plant.x, _plant.y - 5, _plant.depth - 1, obj_stars);
        inst.sprite_index = star_spr;
        inst.parent_card = _plant.id;
        _plant.banding_star_obj = inst.id;
    }
}
