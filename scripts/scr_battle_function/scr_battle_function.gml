
// 消息ID常量（使用s32，方便扩展）
// ============================
// 网络消息ID定义（共17条）
// ============================

#macro MSG_UNIT_REQUEST         1   // C→S: 请求放置我方单位（含类型、等级、网格坐标）
#macro MSG_REMOVE_UNIT          2   // C→S: 请求移除/铲除指定我方单位（携带网络ID）
#macro MSG_CHAT                 3   // C→S: 发送聊天消息（携带文本内容）


#macro MSG_PAUSE_TOGGLE         4   // S→C: 请求暂停/继续游戏（携带暂停状态）
#macro MSG_WAVE_START           5   // S→C: 广播新波次开始（波次编号 + buff字符串）
#macro MSG_SPAWN_UNIT           6   // S→C: 广播创建我方单位（网络ID、类型、等级、坐标、血量等）
#macro MSG_SPAWN_ENEMY          7   // S→C: 广播创建敌人（网络ID、类型、行、列偏移、血量等）
#macro MSG_ENEMY_STATE          8   // S→C: 广播敌人状态变化（网络ID、状态、速度、目标列）
#macro MSG_ENEMY_HP             9   // S→C: 广播敌人血量变化（网络ID、当前血量、最大血量）
#macro MSG_ENEMY_CALIBRATE      10  // S→C: 敌人位置校准（网络ID、世界X、世界Y）
#macro MSG_ENEMY_DESTROYED      11  // S→C: 广播敌人被消灭（网络ID）
#macro MSG_UNIT_HP              12  // S→C: 广播我方单位血量变化（网络ID、当前血量、最大血量）
#macro MSG_UNIT_DESTROYED       13  // S→C: 广播我方单位被摧毁（网络ID）
#macro MSG_GAME_OVER            14  // S→C: 广播游戏结束（结果：0失败/1胜利）
#macro MSG_SUNLIGHT_UPDATE      15  // S→C: 广播阳光/资源数量变化（当前值）
#macro MSG_TIME_UPDATE          16  // S→C: 广播倒计时更新（剩余秒数）
#macro MSG_SYNC_INITIAL_STATE   17  // S→C: 全量状态同步（新客户端加入时发送所有单位、敌人及全局状态）
#macro MSG_START_BATTLE			18	// S→C: 开始战斗
#macro MSG_ENTER_ROOM_READY		19	// S→C: 进入房间


function add_net_id(ins_id){
	ds_map_add(global.network.map_net_id_instance_id,global.network.net_instance_count,ins_id);
	ds_map_add(global.network.map_instance_id_net_id,ins_id,global.network.net_instance_count);
	global.network.net_instance_count++;
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
            // 字段：单位类型ID (u8), 等级 (u8), col (u8), row (u8)
            var level = buffer_read(buf, buffer_u8);
            var col = buffer_read(buf, buffer_u8);
            var row = buffer_read(buf, buffer_u8);
            var object_name = buffer_read(buf, buffer_string);
			var temp_map = ds_map_create();
			var _plant = spawn_plant(col, row, asset_get_index(object_name), temp_map);
			
			add_net_id(_plant.id);
            // TODO: 调用处理函数
            // handle_unit_request(unit_type, level, col, row);
            show_debug_message("[解析] 收到 MSG_UNIT_REQUEST: 类型=" + string(object_name) + " 等级=" + string(level) + " 位置(" + string(col) + "," + string(row) + ")");
            break;
        }
        
        case MSG_REMOVE_UNIT:
        {
            // 字段：网络ID (s32)
            var net_id = buffer_read(buf, buffer_s32);
            // TODO: 调用处理函数
            // handle_remove_unit(net_id);
            show_debug_message("[解析] 收到 MSG_REMOVE_UNIT: 网络ID=" + string(net_id));
            break;
        }
        
        case MSG_PAUSE_TOGGLE:
        {
            // 字段：暂停状态 (u8) 0继续 1暂停
            var pause_state = buffer_read(buf, buffer_u8);
            // TODO: 调用处理函数
            // handle_pause_toggle(pause_state);
            show_debug_message("[解析] 收到 MSG_PAUSE_TOGGLE: 状态=" + string(pause_state));
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
        case MSG_WAVE_START:
        {
            // 字段：波次编号 (u16), buff (string)
            var wave_num = buffer_read(buf, buffer_u16);
            var buff = buffer_read(buf, buffer_string);
            // TODO: 调用处理函数
            // handle_wave_start(wave_num, buff);
            show_debug_message("[解析] 收到 MSG_WAVE_START: 波次=" + string(wave_num) + " buff=" + buff);
            break;
        }
        
        case MSG_SPAWN_UNIT:
        {
            // 字段：网络ID(s32), 等级(u8), col(u8), row(u8), object_name(string)
            var net_id = buffer_read(buf, buffer_s32);
            var level = buffer_read(buf, buffer_u8);
            var col = buffer_read(buf, buffer_u8);
            var row = buffer_read(buf, buffer_u8);
            var object_name = buffer_read(buf, buffer_string);
			
			var temp_map = ds_map_create();
			global.network.plant_able = true;
			var _plant = spawn_plant(col, row, asset_get_index(object_name), temp_map);
			global.network.plant_able = false;
			
			add_net_id(_plant.id);
            // TODO: 调用处理函数
            // handle_spawn_unit(net_id, unit_type, level, col, row, hp, max_hp);
            show_debug_message("[解析] 收到 MSG_SPAWN_UNIT: ID=" + string(net_id) + " 类型=" + object_name + " 等级=" + string(level) + " 位置(" + string(col) + "," + string(row) + ") ");
            break;
        }
        
        case MSG_SPAWN_ENEMY:
        {
            // 字段：网络ID(s32), 敌人类型ID(u8), 行(u8), 出生列偏移(s16), 当前血量(s32), 最大血量(s32)
            var px = buffer_read(buf, buffer_f32);
            var py = buffer_read(buf, buffer_f32);
            var object_name = buffer_read(buf, buffer_string);
			
			
			var new_enemy = instance_create_depth(px, py, 0, asset_get_index(object_name));
			add_net_id(new_enemy.id);
			
			
            // TODO: 调用处理函数
            // handle_spawn_enemy(net_id, enemy_type, row, col_offset, hp, max_hp);
            show_debug_message("[解析] 收到 MSG_SPAWN_ENEMY:" +" 类型=" + object_name+ string(px)+","+string(py) );
            break;
        }
        
        case MSG_ENEMY_STATE:
        {
            // 字段：网络ID(s32), 状态(u8), 速度(f32), 目标列(s16)
            var net_id = buffer_read(buf, buffer_s32);
            var state = buffer_read(buf, buffer_u8);
            //var speed = buffer_read(buf, buffer_f32);
            var target_col = buffer_read(buf, buffer_s16);
            // TODO: 调用处理函数
            // handle_enemy_state(net_id, state, speed, target_col);
            show_debug_message("[解析] 收到 MSG_ENEMY_STATE: ID=" + string(net_id) + " 状态=" + string(state) + " 速度=" + string(speed) + " 目标列=" + string(target_col));
            break;
        }
        
        case MSG_ENEMY_HP:
        {
            // 字段：网络ID(s32), 当前血量(s32), 最大血量(s32)
            var net_id = buffer_read(buf, buffer_s32);
            var hp = buffer_read(buf, buffer_s32);
            var max_hp = buffer_read(buf, buffer_s32);
            // TODO: 调用处理函数
            // handle_enemy_hp(net_id, hp, max_hp);
            show_debug_message("[解析] 收到 MSG_ENEMY_HP: ID=" + string(net_id) + " HP=" + string(hp) + "/" + string(max_hp));
            break;
        }
        
        case MSG_ENEMY_CALIBRATE:
        {
            // 字段：网络ID(s32), 世界X(f32), 世界Y(f32)
            var net_id = buffer_read(buf, buffer_s32);
            var wx = buffer_read(buf, buffer_f32);
            var wy = buffer_read(buf, buffer_f32);
            // TODO: 调用处理函数
            // handle_enemy_calibrate(net_id, wx, wy);
            show_debug_message("[解析] 收到 MSG_ENEMY_CALIBRATE: ID=" + string(net_id) + " 位置(" + string(wx) + "," + string(wy) + ")");
            break;
        }
        
        case MSG_ENEMY_DESTROYED:
        {
            // 字段：网络ID(s32)
            var net_id = buffer_read(buf, buffer_s32);
            // TODO: 调用处理函数
            // handle_enemy_destroyed(net_id);
			
			var eny = global.network.map_net_id_instance_id[net_id];
		    eny.timer = 0;
			eny.state = ENEMY_STATE.DEAD;
			eny.target_plant = noone;  // 清除攻击目标
		
		
            show_debug_message("[解析] 收到 MSG_ENEMY_DESTROYED: ID=" + string(net_id));
            break;
        }
        
        case MSG_UNIT_HP:
        {
            // 字段：网络ID(s32), 当前血量(s32), 最大血量(s32)
            var net_id = buffer_read(buf, buffer_s32);
            var hp = buffer_read(buf, buffer_s32);
            var max_hp = buffer_read(buf, buffer_s32);
            // TODO: 调用处理函数
            // handle_unit_hp(net_id, hp, max_hp);
            show_debug_message("[解析] 收到 MSG_UNIT_HP: ID=" + string(net_id) + " HP=" + string(hp) + "/" + string(max_hp));
            break;
        }
        
        case MSG_UNIT_DESTROYED:
        {
            // 字段：网络ID(s32)
            var net_id = buffer_read(buf, buffer_s32);
            // TODO: 调用处理函数
            // handle_unit_destroyed(net_id);
            show_debug_message("[解析] 收到 MSG_UNIT_DESTROYED: ID=" + string(net_id));
            break;
        }
        
        case MSG_GAME_OVER:
        {
            // 字段：结果(u8) 0失败 1胜利
            var result = buffer_read(buf, buffer_u8);
            // TODO: 调用处理函数
            // handle_game_over(result);
			
            show_debug_message("[解析] 收到 MSG_GAME_OVER: 结果=" + string(result));
            break;
        }
        
        case MSG_SUNLIGHT_UPDATE:
        {
            // 字段：当前阳光值(s32)
            var sunlight = buffer_read(buf, buffer_s32);
            // TODO: 调用处理函数
            // handle_sunlight_update(sunlight);
            show_debug_message("[解析] 收到 MSG_SUNLIGHT_UPDATE: 阳光=" + string(sunlight));
            break;
        }
        
        case MSG_TIME_UPDATE:
        {
            // 字段：剩余秒数(s16)
            var time_left = buffer_read(buf, buffer_s16);
            // TODO: 调用处理函数
            // handle_time_update(time_left);
            show_debug_message("[解析] 收到 MSG_TIME_UPDATE: 剩余时间=" + string(time_left) + "秒");
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

			var target_level_id = json_data[$ "target_level_id"] ?? "";
			var target_level_file = json_data[$ "target_level_file"] ?? "";
			var target_level_file_hard = json_data[$ "target_level_file_hard"] ?? "";
			var level_index = json_data[$ "level_index"] ?? 0;
			global.map_id = json_data[$ "map_id"] ?? "";
			
			
			audio_play_sound(snd_button, 0, 0);
			texture_prefetch("cards")
			if target_level_id != "tower_cake"{
			    global.gui_stack.to(room_ready)
	
				// 这是文件在 datafiles 目录下的相对路径
				global.level_id = target_level_id;
				var _file_path = "level_data/" + target_level_file; 
				if global.difficulty >= 2{
					_file_path = "level_data/" + target_level_file_hard; 
				}


				//使用 load_buffer 和 buffer_read 加载文件内容
				var _buffer = buffer_load(_file_path);
				if (!buffer_exists(_buffer)) {
				    show_debug_message("错误：无法加载关卡文件到缓冲区: " + _file_path);
				} else {
				    var _json_string = buffer_read(_buffer, buffer_string);
				    buffer_delete(_buffer); // 释放缓冲区内存

				    // 解析JSON字符串
				    global.level_file = json_parse(_json_string);
    
				    // 检查解析是否成功
				    if (global.level_file == -1) {
				        show_debug_message("错误：JSON 解析失败！");
				    } else {
				        show_debug_message("关卡文件加载并解析成功！");
				        show_debug_message(global.level_file);
				    }
				}
				var map_button_array = struct_get(ds_map_find_value(global.maps_map,global.map_id),"levels_data")
				global.level_data = map_button_array[level_index]
				show_debug_message(global.level_data)
		
			}
			else{
				global.gui_stack.to(room_tower_cake)
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
        case MSG_UNIT_REQUEST:          // 参数: level(u8), col(u8), row(u8), obj_name(string)
            buffer_write(buf, buffer_u8, argument[2]);
            buffer_write(buf, buffer_u8, argument[3]);
            buffer_write(buf, buffer_u8, argument[4]);
            buffer_write(buf, buffer_string, argument[5]);
            break;
            
        case MSG_REMOVE_UNIT:           // 参数: net_id(s32)
            buffer_write(buf, buffer_s32, argument[2]);
            break;
            
        case MSG_PAUSE_TOGGLE:          // 参数: pause_state(u8)
            buffer_write(buf, buffer_u8, argument[2]);
            break;
            
        case MSG_CHAT:                  // 参数: text(string)
            buffer_write(buf, buffer_string, argument[2]);
            break;
            
        // ======== 服务器广播 ========
        case MSG_WAVE_START:            // 参数: wave_num(u16), buff(string)
            buffer_write(buf, buffer_u16, argument[2]);
            buffer_write(buf, buffer_string, argument[3]);
            break;
            
        case MSG_SPAWN_UNIT:            // 参数: 网络ID(s32), 等级(u8), col(u8), row(u8), object_name(u8)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_u8, argument[3]);
            buffer_write(buf, buffer_u8, argument[4]);
            buffer_write(buf, buffer_u8, argument[5]);
            buffer_write(buf, buffer_string, argument[6]);
			
            break;
            
        case MSG_SPAWN_ENEMY:           // 参数: x,y,type
            buffer_write(buf, buffer_f32, argument[2]);
            buffer_write(buf, buffer_f32, argument[3]);
            buffer_write(buf, buffer_string, argument[4]);
            break;
            
        case MSG_ENEMY_STATE:           // 参数: net_id(s32), state(u8), speed(f32), target_col(s16)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_u8, argument[3]);
            buffer_write(buf, buffer_f32, argument[4]);
            buffer_write(buf, buffer_s16, argument[5]);
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
            
        case MSG_ENEMY_DESTROYED:       // 参数: net_id(s32)
            buffer_write(buf, buffer_s32, argument[2]);
            break;
            
        case MSG_UNIT_HP:               // 参数: net_id(s32), hp(s32), max_hp(s32)
            buffer_write(buf, buffer_s32, argument[2]);
            buffer_write(buf, buffer_s32, argument[3]);
            buffer_write(buf, buffer_s32, argument[4]);
            break;
            
        case MSG_UNIT_DESTROYED:        // 参数: net_id(s32)
            buffer_write(buf, buffer_s32, argument[2]);
            break;
            
        case MSG_GAME_OVER:             // 参数: result(u8)
            buffer_write(buf, buffer_u8, argument[2]);
            break;
            
        case MSG_SUNLIGHT_UPDATE:       // 参数: sunlight(s32)
            buffer_write(buf, buffer_s32, argument[2]);
            break;
            
        case MSG_TIME_UPDATE:           // 参数: time_left(s16)
            buffer_write(buf, buffer_s16, argument[2]);
            break;
            
        case MSG_SYNC_INITIAL_STATE:    // 特殊：这个比较复杂，单独写一个专门函数
            // 略（因为涉及数组循环）
            break;
        case MSG_START_BATTLE:
			break;
		case MSG_ENTER_ROOM_READY:                  // 参数: text(string)
            buffer_write(buf, buffer_string, argument[2]);
            break;
        default:
            show_debug_message("[警告] 未知消息ID: " + string(msg_id));
            return;
    }
    
    // ---- 发送数据包（长度头 + 消息ID + 负载） ----
    var payload_size = buffer_tell(buf);
    var body_size = 4 + payload_size;   // msg_id占4字节
    var packet = buffer_create(body_size + 2, buffer_grow, 1);
	
    buffer_write(packet, buffer_u16, 0);          // 占位
    buffer_write(packet, buffer_s32, msg_id);     // 写入ID
	
    buffer_copy(buf, 0, payload_size, packet, buffer_tell(packet));
    
    buffer_poke(packet, 0, buffer_u16, body_size);
	
	var total_size = buffer_get_size(packet);
	
    network_send_raw(socket, packet, 2+body_size);
	
}