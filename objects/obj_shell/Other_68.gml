var _type = async_load[? "type"];
    
switch (_type) {
    case network_type_connect:
        // 服务器收到新客户端连接
        if (global.network.mode == "server") {
            var _sock = async_load[? "socket"];
			var _len = array_length(global.network.connected_clients);
			var flag = false
			for(var i=0;i<_len;i++){
				if  global.network.connected_clients[i]==_sock{
					flag=true;
					break;
				}
			}
			if(!flag)
				array_push(global.network.connected_clients, _sock);
            
			show_debug_message("[网络] 新客户端连接: " + string(_sock));
			show_notice("[网络] 新客户端连接: " + string(_sock),60)
			send_message(_sock, MSG_CHAT,"收到连接 over");

			// 同步当前房间
			if (room_exists(room_ready) && room == room_ready) {
				var _json = json_stringify({
					target_level_id: global.level_id,
					target_level_file: global.level_data.level_file,
					target_level_file_hard: global.level_data.hard_level_file,
					level_index: global.level_data_index,
					map_id: global.map_id,
					level_data: global.level_data,
					level_file: global.level_file
				});
				send_message(_sock, MSG_ENTER_ROOM_READY, _json);
			}
        }
        break;
            
    case network_type_disconnect:
	    var _sock = async_load[? "socket"];
	    show_debug_message("[网络] 收到断开事件, socket: " + string(_sock) + ", 模式: " + global.network.mode);

	    if (global.network.mode == "server") {
	        // 尝试从列表中移除
	        var _idx = -1;
	        for (var i = 0; i < array_length(global.network.connected_clients); i++) {
	            if (global.network.connected_clients[i] == _sock) {
	                _idx = i;
	                break;
	            }
	        }
			
	        if (_idx != -1) {
	            array_delete(global.network.connected_clients, _idx, 1);
	            show_debug_message("[网络] 客户端断开并从列表移除: " + string(_sock));
	        } else {
	            show_debug_message("[网络] 客户端断开但未在列表中找到: " + string(_sock));
	        }
			
			shell_print("客户端"+string(_sock)+" 断开连接");
			show_notice("客户端"+string(_sock)+" 断开连接",60);
	    } 
		else if (global.network.mode == "client") {
			sh_disconnect();
			shell_print("与服务器断开连接");
			show_notice("与服务器断开连接",60);
	        show_debug_message("[网络] 与服务器断开连接");
	    } 
		else {
	        show_debug_message("[网络] 断开事件但模式未知: " + global.network.mode);
	    }
	    break;
            
    case network_type_data:
		var _buf = async_load[? "buffer"];
		var _len = buffer_get_size(_buf);
		if (_len <= 0) break;
		
		// 1. 追加新收到的数据到全局接收buffer
		buffer_copy(_buf, 0, _len, global.recv_buf, global.recv_size);
		global.recv_size += _len;
		var read_ptr = 0;
		while (global.recv_size - read_ptr >= 2)
		{
		    // 读取小端u16包长度
		    var len = buffer_peek(global.recv_buf, read_ptr, buffer_u16);
		    var full_pkt = 2 + len;
		    if (read_ptr + full_pkt > global.recv_size) break;
		    var body = buffer_create(len, buffer_fixed, 1);
		    buffer_copy(global.recv_buf, read_ptr + 2, len, body, 0);
		    parse_network_message(body);
		    buffer_delete(body);
		    read_ptr += full_pkt;
		}

		// 2. 安全裁剪缓冲区：使用临时中转buffer，杜绝同buffer拷贝报错
		var remain_len = global.recv_size - read_ptr;
		if (remain_len > 0)
		{
		    var temp_buf = buffer_create(remain_len, buffer_fixed, 1);
		    buffer_copy(global.recv_buf, read_ptr, remain_len, temp_buf, 0);
		    buffer_seek(global.recv_buf, buffer_seek_start, 0);
		    buffer_copy(temp_buf, 0, remain_len, global.recv_buf, 0);
		    buffer_delete(temp_buf);
		}
		global.recv_size = remain_len;

		break;
	
            
    default:
        show_debug_message("[网络] 未知事件类型: " + string(_type));
        break;
}