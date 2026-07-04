

// ============================
// 网络消息ID定义
// ============================

#macro MSG_UNIT_REQUEST         1   // C→S: 请求放置我方单位（含类型、等级、网格坐标）
#macro MSG_REMOVE_UNIT_REQUEST  2   // C→S: 请求移除/铲除指定我方单位（携带网络ID）
#macro MSG_CHAT                 3   // C→S: 发送聊天消息（携带文本内容）
#macro MSG_ACTIVE_SKILL_REQUEST 4   // C→S: 请求释放主动技能


#macro MSG_SPAWN_UNIT           5   // S→C: 广播创建我方单位（网络ID、类型、等级、坐标、血量等）
#macro MSG_SPAWN_ENEMY          6   // S→C: 广播创建敌人（网络ID、类型、行、列偏移、血量等）
#macro MSG_ENEMY_HP             7   // S→C: 广播敌人血量变化（网络ID、当前血量、最大血量）
#macro MSG_ENEMY_CALIBRATE      8   // S→C: 敌人位置校准（网络ID、世界X、世界Y）
#macro MSG_UNIT_HP              9   // S→C: 广播我方单位血量变化（网络ID、当前血量、最大血量）
#macro MSG_GAME_OVER            10  // S→C: 广播游戏结束（结果：0失败/1胜利）
#macro MSG_SYNC_INITIAL_STATE   11  // S→C: 全量状态同步（新客户端加入时发送所有单位、敌人及全局状态）
#macro MSG_START_BATTLE			12	// S→C: 开始战斗
#macro MSG_ENTER_ROOM_READY		13	// S→C: 进入房间
#macro MSG_SPAWN_BOSS           14  // S→C: 广播产生BOSS
#macro MSG_REMOVE_UNIT          15  // S→C: 广播移除/铲除指定我方单位
#macro MSG_ENEMY_STEAL          16  // S→C: 广播敌方偷取植物
#macro MSG_PROGRESS_SYNC        17  // S→C: 广播进度条同步
#macro MSG_ACTIVE_SKILL         18  // S→C: 广播释放主动技能
#macro MSG_SERVER_ACTION        19  // S→C: 0正常/1加速/2暂停/3继续/4回房/5重开
#macro MSG_EVENT_ACTIONS        20  // S→C: event_manager 操作日志(JSON)
#macro MSG_DESTROY              21  // S→C: 广播销毁实例
#macro MSG_CAT_ATTACK           22  // S→C: 猫撞击敌人(row, sprite_name, image_index)
#macro MSG_PUB_INFO             23  // M→A: 中继器到所有人发消息
#macro MSG_MUSIC_SYNC           24  // S→C: 广播音乐切换

/// @function add_net_id(ins_id, net_id)
/// @description 为实例产生一个 net_id
function add_net_id(ins_id){
	ds_map_add(global.network.map_net_id_instance_id,global.network.net_instance_count,ins_id);
	ds_map_add(global.network.map_instance_id_net_id,ins_id,global.network.net_instance_count);
	global.network.net_instance_count++;
}

/// @function set_net_id(ins_id, net_id)
/// @description 用服务端分配的 net_id 注册实例，保证两端一致
function set_net_id(ins_id, net_id){
	ds_map_add(global.network.map_net_id_instance_id, net_id, ins_id);
	ds_map_add(global.network.map_instance_id_net_id, ins_id, net_id);
	if (net_id >= global.network.net_instance_count) {
		global.network.net_instance_count = net_id + 1;
	}
}


/// @function shell_print(msg)
/// @param {string} msg  打印消息到shell中
function shell_print(msg) {
	inst_id = inst_224771E1; 
    // 检查实例是否存在
    if (!instance_exists(inst_id)) {
        show_debug_message("[shell_push_output] 实例 " + string(inst_id) + " 不存在");
        return;
    }
    
    // 通过 with 操作该实例
    with (inst_id) {
        // 检查 output 数组是否存在
        if (!variable_struct_exists(self, "output")) {
            show_debug_message("[shell_push_output] 实例 " + string(inst_id) + " 没有 output 数组");
            return;
        }
        // 压入消息
        array_push(output, msg);
    }
}


/// @function parse_network_message(buffer)
/// @param {buffer} buf  完整的消息体缓冲区（已剥去长度头）
/// @description 读取消息ID并分发到对应的处理函数
function parse_network_message(buf) {
    // 确保从缓冲区开头读取
    buffer_seek(buf, buffer_seek_start, 0);
    
    // 1. 读取消息ID（4字节整数）
    var msg_id = buffer_read(buf, buffer_s32);
    
    // 2. 根据消息ID分发
    switch (msg_id) {
        // ========== 客户端请求 ==========
        case MSG_UNIT_REQUEST:
        {
            // 字段：level(u8), col(u8), row(u8), skill(u8), shape(u8), obj_name(string), meta_info(string)
            var level = buffer_read(buf, buffer_u8);
            var col = buffer_read(buf, buffer_u8);
            var row = buffer_read(buf, buffer_u8);
            var skill = buffer_read(buf, buffer_u8);
            var shape = buffer_read(buf, buffer_u8);
            var object_name = buffer_read(buf, buffer_string);
            var meta = buffer_read(buf, buffer_string);
			var _sprite_name = buffer_read(buf, buffer_string);
			
			
			var _props = { "current_level": level, "skill": skill, "shape": shape };
			if (meta != "") {
				var _st = json_parse(meta);
				var _keys = variable_struct_get_names(_st);
				for (var i = 0; i < array_length(_keys); i++) {
					var _key = _keys[i];
					_props[$ _key] = _st[$ _key];
				}
			}
			if (_sprite_name != "") { _props[$ "sprite_index"] = asset_get_index(_sprite_name); }
			
            var _plant = spawn_plant(col, row, asset_get_index(object_name), _props);
			network_apply_plant_level(_plant);
            add_net_id(_plant.id);

            show_debug_message("[解析] MSG_UNIT_REQUEST: type=" + object_name + " Lv=" + string(level)+" meta="+meta);
            break;
        }
        
        case MSG_REMOVE_UNIT_REQUEST:
        {
            // 字段：net_id(s32), col(u8), row(u8), flame_amount(s32)
            var net_id = buffer_read(buf, buffer_s32);
            var col = buffer_read(buf, buffer_u8);
            var row = buffer_read(buf, buffer_u8);
            var flame_amount = buffer_read(buf, buffer_s32);

            network_shovel_remove(col, row, net_id, flame_amount);
            network_broadcast_shovel_remove(col, row, net_id, flame_amount);

            show_debug_message("[解析] 收到 MSG_REMOVE_UNIT_REQUEST: ID=" + string(net_id) + " col=" + string(col) + " row=" + string(row) + " flame=" + string(flame_amount));
            break;
        }

        case MSG_REMOVE_UNIT:
        {
            // 字段：net_id(s32), col(u8), row(u8), flame_amount(s32)
            var net_id = buffer_read(buf, buffer_s32);
            var col = buffer_read(buf, buffer_u8);
            var row = buffer_read(buf, buffer_u8);
            var flame_amount = buffer_read(buf, buffer_s32);

            // 客户端执行铲除（放行 instance_destroy）
            global.network.client_able = true;
            network_shovel_remove(col, row, net_id, flame_amount);
            global.network.client_able = false;

            show_debug_message("[解析] 收到 MSG_REMOVE_UNIT: ID=" + string(net_id) + " col=" + string(col) + " row=" + string(row));
            break;
        }

        
        
        case MSG_CHAT:
        {
			var _str = "";
			for (var i = 0; i < buffer_get_size(buf); i++) _str += string(buffer_peek(buf, i, buffer_u8)) + " ";
            var chat_text = buffer_read(buf, buffer_string);
            show_debug_message("[解析] 收到 MSG_CHAT: " + chat_text);
			shell_print(chat_text);
			if global.network.mode == "server"{
				sh_say(chat_text);
			}
            break;
        }
        
        // ========== 服务器广播 ==========
        
        
        case MSG_SPAWN_UNIT:
        {
            // 字段：net_id(s32), level(u8), col(u8), row(u8), skill(u8), shape(u8), object_name(string), meta_info(string)
            var net_id = buffer_read(buf, buffer_s32);
            var level = buffer_read(buf, buffer_u8);
            var col = buffer_read(buf, buffer_u8);
            var row = buffer_read(buf, buffer_u8);
            var skill = buffer_read(buf, buffer_u8);
            var shape = buffer_read(buf, buffer_u8);
            var _sprite_name = buffer_read(buf, buffer_string);
            var object_name = buffer_read(buf, buffer_string);
            var meta = buffer_read(buf, buffer_string);

			var _props = { "current_level": level, "skill": skill, "shape": shape };
			if (meta != "") {
			    var _st = json_parse(meta);
			    var _keys = variable_struct_get_names(_st);
			    for (var i = 0; i < array_length(_keys); i++) {
			        var _key = _keys[i];
			        _props[$ _key] = _st[$ _key];
			    }
			}
			if (_sprite_name != "") {
			    _props[$ "sprite_index"] = asset_get_index(_sprite_name);
			}

            global.network.client_able = true;
            var _plant = spawn_plant(col, row, asset_get_index(object_name), _props);
            global.network.client_able = false;
			
			network_apply_plant_level(_plant);
            set_net_id(_plant.id, net_id);

            show_debug_message("[解析] MSG_SPAWN_UNIT: ID=" + string(net_id) + " type=" + object_name + " Lv=" + string(level)+" meta="+meta);
            break;

        }
        
        case MSG_SPAWN_ENEMY:
        {
            // 字段：网络ID(s32), x(f32), y(f32), object_name(string)
            var net_id = buffer_read(buf, buffer_s32);
            var px = buffer_read(buf, buffer_f32);
            var py = buffer_read(buf, buffer_f32);
            var object_name = buffer_read(buf, buffer_string);
			
			global.network.client_able = true;
            var new_enemy = instance_create_depth(px, py, 0, asset_get_index(object_name));
			global.network.client_able = false;
            set_net_id(new_enemy.id, net_id);

            show_debug_message("[解析] MSG_SPAWN_ENEMY: ID=" + string(net_id) + " type=" + object_name);
            break;
        }

        case MSG_SPAWN_BOSS:
        {
            // 字段：net_id(s32), x(f32), y(f32), object_name(string), hp(s32), maxhp(s32), row(u8)
            var net_id = buffer_read(buf, buffer_s32);
            var px = buffer_read(buf, buffer_f32);
            var py = buffer_read(buf, buffer_f32);
            var object_name = buffer_read(buf, buffer_string);
            var hp_val = buffer_read(buf, buffer_s32);
            var maxhp_val = buffer_read(buf, buffer_s32);
            var boss_row = buffer_read(buf, buffer_u8);
	
			global.network.client_able = true;
            var new_boss = instance_create_depth(px, py, -200, asset_get_index(object_name));
			global.network.client_able = false;
            set_net_id(new_boss.id, net_id);
            new_boss.hp = hp_val;
            new_boss.maxhp = maxhp_val;
            new_boss.grid_row = boss_row;
            obj_battle.boss_count++;
			

            show_debug_message("[解析] MSG_SPAWN_BOSS: ID=" + string(net_id) + " type=" + object_name + " HP=" + string(hp_val) + "/" + string(maxhp_val));
            break;
        }


        
        case MSG_ENEMY_HP:
        {
            // 字段：网络ID(s32), 当前血量(s32), 最大血量(s32)
            var net_id = buffer_read(buf, buffer_s32);
            var hp_val = buffer_read(buf, buffer_s32);
            var max_hp = buffer_read(buf, buffer_s32);
            var _inst = global.network.map_net_id_instance_id[? net_id];
            if (instance_exists(_inst)) {
                // 客户端已判定死亡但未收到确认时不覆盖（防止复活）
                if (!(_inst.hp <= 0 && _inst.state != ENEMY_STATE.DEAD)) {
                    _inst.hp = hp_val;
                    _inst.maxhp = max_hp;
                }
            }
            //show_debug_message("[解析] 收到 MSG_ENEMY_HP: ID=" + string(net_id) + " HP=" + string(hp_val) + "/" + string(max_hp));
            break;
        }
        case MSG_ENEMY_CALIBRATE:
        {
            // 字段：网络ID(s32), 世界X(f32), 世界Y(f32)
            var net_id = buffer_read(buf, buffer_s32);
            var wx = buffer_read(buf, buffer_f32);
            var wy = buffer_read(buf, buffer_f32);
            var _inst = global.network.map_net_id_instance_id[? net_id];
            if (instance_exists(_inst)) {
                _inst.x = wx;
                _inst.y = wy;
            }
            //show_debug_message("[解析] 收到 MSG_ENEMY_CALIBRATE: ID=" + string(net_id) + " 位置(" + string(wx) + "," + string(wy) + ")");
            break;
        }
        
        case MSG_UNIT_HP:
        {
            // 字段：net_id(s32), hp(s32), max_hp(s32)
            var net_id = buffer_read(buf, buffer_s32);
            var hp_val = buffer_read(buf, buffer_s32);
            var max_hp = buffer_read(buf, buffer_s32);
            var _inst = global.network.map_net_id_instance_id[? net_id];
            if (instance_exists(_inst)) {
                _inst.hp = hp_val;
                _inst.max_hp = max_hp;
            }
            break;
		}


        case MSG_DESTROY:
        {
            var _net_id = buffer_read(buf, buffer_s32);
            var _inst = global.network.map_net_id_instance_id[? _net_id];
			// 延迟销毁，避免销毁后野指针访问
			if (instance_exists(_inst)) {
				_inst.pending_destroy = true;
				_inst.visible = false;  
				ds_list_add(global._destroy_queue, {inst: _inst, timer: 60});
			}
			/*
            if (instance_exists(_inst)) {
				global.network.client_able = true;
                instance_destroy(_inst);
				global.network.client_able = false;
            }*/
            break;
		}
        case MSG_CAT_ATTACK:
        {
            var _row = buffer_read(buf, buffer_u8);
            with (obj_cat) {
                if (self.row == _row) {
                    self.state ="awake"
                }
            }
            break;
        }
        

        case MSG_ENEMY_STEAL:
        {
            // 字段：net_id(s32), col(u8), row(u8)
            var net_id = buffer_read(buf, buffer_s32);
            var col = buffer_read(buf, buffer_u8);
            var row = buffer_read(buf, buffer_u8);

            // 执行偷取
            network_enemy_steal(col, row, net_id);

            // 服务端收到客户端请求后广播给所有客户端
            if (global.network.mode == "server") {
                network_broadcast_enemy_steal(col, row, net_id);
            }

            show_debug_message("[解析] 收到 MSG_ENEMY_STEAL: ID=" + string(net_id) + " col=" + string(col) + " row=" + string(row));
            break;

        }
        case MSG_PROGRESS_SYNC:
        {
            var wave = buffer_read(buf, buffer_u8);
            var subwave = buffer_read(buf, buffer_u8);
            obj_battle.current_wave = wave;
            obj_battle.current_subwave = subwave;
            break;
        }

        case MSG_MUSIC_SYNC:
        {
            var _music = buffer_read(buf, buffer_s32);
            with (obj_battle_music_controller) {
                new_battle_music = _music;
                event_user(0);
            }
            break;
        }

        case MSG_ACTIVE_SKILL_REQUEST:
        {
            var _type = buffer_read(buf, buffer_string);
            var _col = buffer_read(buf, buffer_u8);
            var _row = buffer_read(buf, buffer_u8);
            var _level = buffer_read(buf, buffer_u8);
            var _coords = buffer_read(buf, buffer_string);
            _coords = network_active_skill(_type, _col, _row, _level, _coords);
            network_broadcast_active_skill(_type, _col, _row, _level, _coords);
            break;
        }

        case MSG_ACTIVE_SKILL:
        {
            var _type = buffer_read(buf, buffer_string);
            var _col = buffer_read(buf, buffer_u8);
            var _row = buffer_read(buf, buffer_u8);
            var _level = buffer_read(buf, buffer_u8);
            var _coords = buffer_read(buf, buffer_string);
            network_active_skill(_type, _col, _row, _level, _coords);
            break;
		}

        case MSG_SERVER_ACTION:
        {
            var _act = buffer_read(buf, buffer_u8);
            switch (_act) {
                case 0: game_set_speed(60, gamespeed_fps); obj_battle.speed_up = false; break;
                case 1: game_set_speed(120, gamespeed_fps); obj_battle.speed_up = true; break;
                case 2: global.is_paused = true; break;
                case 3: global.is_paused = false; break;
                case 4: global.gui_stack.to(room_ready); break;
                case 5: global.gui_stack.pop(); room_goto(room_battle); break;
            }
            break;
        }

        case MSG_EVENT_ACTIONS:
        {
			global.network.client_able = true;
            var _json = buffer_read(buf, buffer_string);
            var _actions = json_parse(_json);
            for (var _i = 0; _i < array_length(_actions); _i++) {
                var _act = _actions[_i];
                switch (_act.op) {
                    case "spawn":
                        // BOSS血条由BOSS自身Create事件创建，不需要网络同步
                        if (_act.obj == "obj_boss_hpbar") break;
                        var _inst = instance_create_depth(_act.x, _act.y, _act.depth, asset_get_index(_act.obj));
                        set_net_id(_inst.id, _act.net_id);
                        with (_inst) {
                            var _props = _act.props;
                            var _keys = struct_get_names(_props);
                            for (var _k = 0; _k < array_length(_keys); _k++) {
                                var _key = _keys[_k];
                                variable_instance_set(id, _key, _props[$ _key]);
                            }
                        }
                        break;
                    case "destroy":
                        if (instance_exists(_act.id)) instance_destroy(_act.id);
                        break;
					case "state":
						if (_act.key == "grid_terrains") global.grid_terrains = json_parse(_act.val);
						if (_act.key == "row_feature")   global.row_feature   = json_parse(_act.val);
						break;
                }
            }
			
			global.network.client_able = false;
            break;
        }
        

        case MSG_GAME_OVER:
        {
            // 字段：结果(u8) 0失败 1胜利
            var result = buffer_read(buf, buffer_u8);
            // TODO: 调用处理函数
            // handle_game_over(result);
			global.is_paused = true;
			global.game_over = true;
			if result==1{
				var inst = instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over);
				inst.sprite_index = spr_win;
				audio_play_sound(snd_win,0,0);
			}else{

				instance_create_depth(room_width/2,room_height/2,-3001,obj_game_over);
				audio_play_sound(snd_lose,0,0);
			}
			
            show_debug_message("[解析] 收到 MSG_GAME_OVER: 结果=" + string(result));
            break;
        }
        

        
        case MSG_SYNC_INITIAL_STATE:
        {
            // 注意：此消息结构复杂，需按顺序读取
            // 我们先读植物列表
            var unit_count = buffer_read(buf, buffer_u16);
            for (var i = 0; i < unit_count; i++) {
                var net_id = buffer_read(buf, buffer_s32);
                var unit_type = buffer_read(buf, buffer_u8);
                var level = buffer_read(buf, buffer_u8);
                var col = buffer_read(buf, buffer_u8);
                var row = buffer_read(buf, buffer_u8);
                var hp = buffer_read(buf, buffer_s32);
                var max_hp = buffer_read(buf, buffer_s32);
                // TODO: 将信息保存到临时列表，待全量解析完成后统一处理
                // 或者直接调用 add_unit_from_sync(...)
            }
            // 再读敌人列表
            var enemy_count = buffer_read(buf, buffer_u16);
            for (var i = 0; i < enemy_count; i++) {
                var net_id = buffer_read(buf, buffer_s32);
                var enemy_type = buffer_read(buf, buffer_u8);
                var row = buffer_read(buf, buffer_u8);
                var wx = buffer_read(buf, buffer_f32);
                var wy = buffer_read(buf, buffer_f32);
                var hp = buffer_read(buf, buffer_s32);
                var max_hp = buffer_read(buf, buffer_s32);
                var state = buffer_read(buf, buffer_u8);
                //var speed = buffer_read(buf, buffer_f32);
                // TODO: 同样保存或直接创建
            }
            // 最后读全局状态
            var sunlight = buffer_read(buf, buffer_s32);
            var time_left = buffer_read(buf, buffer_s16);
            // TODO: 调用 handle_initial_sync(units, enemies, sunlight, time_left);
            show_debug_message("[解析] 收到 MSG_SYNC_INITIAL_STATE: 植物数=" + string(unit_count) + " 敌人数=" + string(enemy_count) + " 阳光=" + string(sunlight) + " 时间=" + string(time_left));
            break;
        }
		
		case MSG_START_BATTLE:
		{
            show_debug_message("[解析] 收到 MSG_START_BATTLE: 开始战斗");
			global.gui_stack.to(room_battle)
			ds_map_clear(global.network.map_instance_id_net_id)
			ds_map_clear(global.network.map_net_id_instance_id)
			global.network.net_instance_count=0
			texture_prefetch("bullet")
			texture_prefetch("effects")
			break;
		}
		
		case MSG_ENTER_ROOM_READY:
		{
		    show_debug_message("[解析] 收到 MSG_ENTER_ROOM_READY: 进入房间");
			
			var json_text = buffer_read(buf, buffer_string);
			var json_data;
			try
			{
			    json_data = json_parse(json_text);
			}
			catch(_)
			{
			    show_debug_message("JSON损坏：" + json_text);
			    return;
			}

			global.map_id      = json_data[$ "map_id"] ?? "";
			global.level_index = json_data[$ "level_index"] ?? 0;
			global.level_id    = json_data[$ "target_level_id"] ?? "";
			global.level_data  = json_data[$ "level_data"];
			global.level_file  = json_data[$ "level_file"];
			
			if( global.level_file!= undefined&& global.level_file!= undefined){
				audio_play_sound(snd_button, 0, 0);
				texture_prefetch("cards");
				global.gui_stack.to(room_ready);
			}

			break;
		}
		
		
		case MSG_PUB_INFO:
		{
			var chat_text = buffer_read(buf, buffer_string);
			show_debug_message("[解析] 收到 MSG_PUB_INFO: " + chat_text);

	
			switch (chat_text) {
				case "\\modserver":
				    global.network.mode = "server";
				    global.network.connected_clients = [global.network.server_socket];
				    global.network.server_port = global.network.target_port;
				    // 同步房间信息给中继
				    if (room_exists(room_ready) && room == room_ready) {
				        var _json = json_stringify({
				            target_level_id: global.level_id,
				            target_level_file: global.level_data.level_file,
				            target_level_file_hard: global.level_data.hard_level_file,
				            level_index: global.level_data_index,
				            map_id: global.map_id
				        });
				        send_message(global.network.server_socket, MSG_CHAT, "\\syncroom " + _json);
				    }
				    break;
				case "\\modclient":
				    break;
				case "\\host_left":
				    shell_print("[系统] 房主已离开，房间关闭");
				    sh_disconnect();
				    break;
				case "\\kicked":
				    shell_print("[系统] 你被房主踢出了房间");
				    sh_disconnect();
				    break;
				default:
					shell_print(chat_text);
					
			}
	
			break;
		}
		
        default:
        {
            show_debug_message("[解析] 警告：未知消息ID " + string(msg_id) + "，跳过该消息");
            break;
        }
    }
}


/// @function send_message(socket, msg_id, ...)
/// @param {real} socket  网络套接字
/// @param {real} msg_id  消息ID常量
/// @param {...} 可变参数，按协议顺序传入字段值
/// @description 自动根据 msg_id 打包并发送，支持所有消息类型
function send_message(socket, msg_id) {
    // 创建缓冲区（grow模式会自动扩容）
	
	show_debug_message("发送数据");
	
    var buf = buffer_create(1024, buffer_grow, 1);
    
    // 根据消息ID写入对应的字段
    switch (msg_id) {
        // ======== 客户端请求 ========
        case MSG_UNIT_REQUEST:          // 参数: level(u8), col(u8), row(u8), skill(u8), shape(u8), obj_name(string), meta_info(string), sprite_name(string)
            buffer_write(buf, buffer_u8, argument[2]);
            buffer_write(buf, buffer_u8, argument[3]);
            buffer_write(buf, buffer_u8, argument[4]);
            buffer_write(buf, buffer_u8, argument[5]);
            buffer_write(buf, buffer_u8, argument[6]);
            buffer_write(buf, buffer_string, argument[7]);
            buffer_write(buf, buffer_string, argument[8]);
            buffer_write(buf, buffer_string, argument[9]);
            break;
            
		case MSG_REMOVE_UNIT_REQUEST:      // 参数: net_id(s32), col(u8), row(u8), flame_amount(s32)
			buffer_write(buf, buffer_s32, argument[2]);
			buffer_write(buf, buffer_u8, argument[3]);
			buffer_write(buf, buffer_u8, argument[4]);
			buffer_write(buf, buffer_s32, argument[5]);
			break;

		case MSG_REMOVE_UNIT:           // 参数: net_id(s32), col(u8), row(u8), flame_amount(s32)
			buffer_write(buf, buffer_s32, argument[2]);
			buffer_write(buf, buffer_u8, argument[3]);
			buffer_write(buf, buffer_u8, argument[4]);
			buffer_write(buf, buffer_s32, argument[5]);
		case MSG_ENEMY_STEAL:           // 参数: net_id(s32), col(u8), row(u8)
			buffer_write(buf, buffer_s32, argument[2]);
			buffer_write(buf, buffer_u8, argument[3]);
			buffer_write(buf, buffer_u8, argument[4]);
			break;

		case MSG_PROGRESS_SYNC:         // 参数: current_wave(u8), current_subwave(u8)
			buffer_write(buf, buffer_u8, argument[2]);
			buffer_write(buf, buffer_u8, argument[3]);
			break;

		case MSG_ACTIVE_SKILL_REQUEST:  // 参数: skill_type(string), col(u8), row(u8), level(u8), coords_json(string)
		case MSG_ACTIVE_SKILL:          // 参数: skill_type(string), col(u8), row(u8), level(u8), coords_json(string)
			buffer_write(buf, buffer_string, argument[2]);
			buffer_write(buf, buffer_u8, argument[3]);
			buffer_write(buf, buffer_u8, argument[4]);
			buffer_write(buf, buffer_u8, argument[5]);
			buffer_write(buf, buffer_string, argument_count > 6 ? argument[6] : "");
			break;

		case MSG_SERVER_ACTION:         // 参数: action(u8)
			buffer_write(buf, buffer_u8, argument[2]);
			break;
				break;
            

            
        case MSG_CHAT:                  // 参数: text(string)
            buffer_write(buf, buffer_string, argument[2]);
            break;
            
        // ======== 服务器广播 ========
            
        case MSG_SPAWN_UNIT:            // 参数: 网络ID(s32), level(u8), col(u8), row(u8), skill(u8), shape(u8), sprite_name(string), object_name(string), meta_info(string)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_u8, argument[3]);
            buffer_write(buf, buffer_u8, argument[4]);
            buffer_write(buf, buffer_u8, argument[5]);
            buffer_write(buf, buffer_u8, argument[6]);
            buffer_write(buf, buffer_u8, argument[7]);
            buffer_write(buf, buffer_string, argument[8]);
            buffer_write(buf, buffer_string, argument[9]);
            buffer_write(buf, buffer_string, argument[10]);
            break;
            
        case MSG_SPAWN_ENEMY:           // 参数: net_id(s32), x(f32), y(f32), object_name(string)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_f32, argument[3]);
            buffer_write(buf, buffer_f32, argument[4]);
            buffer_write(buf, buffer_string, argument[5]);
            break;

        case MSG_SPAWN_BOSS:            // 参数: net_id(s32), x(f32), y(f32), object_name(string), hp(s32), maxhp(s32), row(u8)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_f32, argument[3]);
            buffer_write(buf, buffer_f32, argument[4]);
            buffer_write(buf, buffer_string, argument[5]);
            buffer_write(buf, buffer_s32, argument[6]);
            buffer_write(buf, buffer_s32, argument[7]);
            buffer_write(buf, buffer_u8, argument[8]);
            break;
            break;

            
        case MSG_ENEMY_HP:              // 参数: net_id(s32), hp(s32), max_hp(s32)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_s32, argument[3]);
            buffer_write(buf, buffer_s32, argument[4]);
            break;
            
        case MSG_ENEMY_CALIBRATE:       // 参数: net_id(s32), wx(f32), wy(f32)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_f32, argument[3]);
            buffer_write(buf, buffer_f32, argument[4]);
            break;
            

        case MSG_DESTROY:              // 参数: net_id(s32)
            buffer_write(buf, buffer_s32, argument[2]);
            break;
        case MSG_CAT_ATTACK:           // 参数: row(u8)
            buffer_write(buf, buffer_u8, argument[2]);
            break;

        case MSG_UNIT_HP:               // 参数: net_id(s32), hp(s32), max_hp(s32), x(f32), y(f32)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_s32, argument[3]);
            buffer_write(buf, buffer_s32, argument[4]);
            break;

        case MSG_GAME_OVER:             // 参数: result(u8)
            buffer_write(buf, buffer_u8, argument[2]);
            break;
            
            
            
        case MSG_SYNC_INITIAL_STATE:    // 特殊：这个比较复杂，单独写一个专门函数
            // 略（因为涉及数组循环）
            break;
        case MSG_START_BATTLE:
			break;
		case MSG_ENTER_ROOM_READY:                  // 参数: text(string)
            buffer_write(buf, buffer_string, argument[2]);
            break;
        case MSG_EVENT_ACTIONS:         // 参数: json(string)
            buffer_write(buf, buffer_string, argument[2]);
            break;
        case MSG_MUSIC_SYNC:               // 参数: music_asset(s32)
            buffer_write(buf, buffer_s32, argument[2]);
            break;
        default:
            show_debug_message("[警告] 未知消息ID: " + string(msg_id));
            return;
    }
    
    // ---- 发送数据包（长度头 + 消息ID + 负载） ----
    var payload_size = buffer_tell(buf);
    var body_size = 4 + payload_size;   // msg_id占4字节
    // 限制最大4MB-4，超出截断
    var max_body = 4194300;
    if (body_size > max_body) { body_size = max_body; }
    var packet = buffer_create(body_size + 4, buffer_grow, 1);
	
    buffer_write(packet, buffer_u32, 0);          // 占位
    buffer_write(packet, buffer_s32, msg_id);     // 写入ID
	
    buffer_copy(buf, 0, payload_size, packet, buffer_tell(packet));
    
    buffer_poke(packet, 0, buffer_u32, body_size);
	
	var total_size = buffer_get_size(packet);
	
    network_send_raw(socket, packet, 4+body_size);
	
}