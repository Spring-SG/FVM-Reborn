// ============================================================
// 全局网络状态定义
// ============================================================
global.network = {
    mode: "offline",
    plant_able: true,
    server_socket: -1,
    server_ip: "",
    server_port: 27085,
    connected_clients: [],
    client_socket: -1,
    target_ip: "",
    target_port: 27085,
    is_connected: false,
    max_clients: 32,
	net_instance_count: 0,
	map_net_id_instance_id:ds_map_create(),
	map_instance_id_net_id:ds_map_create()
};


// ============================================================
// 网络命令函数 (rt-shell)
// ============================================================

function sh_makeserver(args) {
    if (global.network.mode != "offline") {
        return "[网络] 已有网络连接，请先关闭";
    }
    
    var _port = global.network.server_port;
    if (array_length(args) > 1) {
        _port = real(args[1]);
        if (_port <= 0 || _port > 65535) {
            return "[网络] 端口号无效，请输入 1-65535 之间的数值";
        }
    }
    
    var _socket = network_create_server_raw(network_socket_tcp, _port, global.network.max_clients);
    if (_socket > 0) {
        global.network.mode = "server";
        global.network.server_socket = _socket;
        global.network.server_port = _port;
        global.network.connected_clients = [];
        global.network.server_ip = "127.0.0.1";
        return "[网络] 服务器已启动，IP: " + global.network.server_ip + " 端口: " + string(_port);
    } else {
        return "[网络] 创建服务器失败，端口可能被占用";
    }
}

function connecttest(args) {
    if (global.network.mode != "server") {
        return "[网络] 服务器未启动";
    }

    // 1. 创建客户端套接字
    var _client = network_create_socket(network_socket_tcp);
    if (_client < 0) {  // 失败返回 -1
        return "[网络] 创建套接字失败";
    }

    // 2. 发起连接
    var _success = network_connect_raw(_client, "127.0.0.1", global.network.server_port);
    if (_success < 0) {  // 失败返回 -1，成功返回 >=0
        return "[网络] 连接失败";
    }


    // 4. 发送测试消息
    var _buf = buffer_create(1024, buffer_fixed, 1);
    buffer_write(_buf, buffer_string, "Hello from client");
    var _size = buffer_tell(_buf);
    buffer_seek(_buf, buffer_seek_start, 0);
    network_send_raw(_client, _buf, _size);
    buffer_delete(_buf);

    // 6. 断开连接
    network_destroy(_client);

    return "[网络] 连接测试完成";
}


function sh_closeserver() {
    if (global.network.mode != "server") {
        return "[网络] 当前不是服务器模式";
    }

    // 断开所有客户端连接
    var _clients = global.network.connected_clients;
    for (var i = 0; i < array_length(_clients); i++) {
        network_destroy(_clients[i]);  // 使用 network_destroy
    }

    // 关闭服务器套接字
    if (global.network.server_socket != -1) {
        network_destroy(global.network.server_socket); 
    }

    global.network.mode = "offline";
    global.network.server_socket = -1;
    global.network.connected_clients = [];
    global.network.server_ip = "";

    return "[网络] 服务器已关闭";
}


function sh_connectserver(args) {
    if (global.network.mode != "offline") {
        return "[网络] 已有网络连接，请先断开";
    }
	
    if (array_length(args) < 2) {
        return "[网络] 用法: connectserver <IP> <端口>";
    }
	var _ip="127.0.0.1";
	var _port = 0;
	if (array_length(args) == 2){
		_port = real(args[1]);
	}else{
	    _ip = args[1];
		_port = real(args[2]);
	}

    if (_port <= 0 || _port > 65535) {
        return "[网络] 端口号无效，请输入 1-65535 之间的数值";
    }
    var _sock = network_create_socket(network_socket_tcp);
    if (_sock < 0) {
        return "[网络] 创建 socket 失败";
    }
    var _result = network_connect_raw(_sock, _ip, _port);
    if (_result >= 0) {
        global.network.mode = "client";
        global.network.server_socket = _sock;
		global.network.plant_able = false;
        global.network.target_ip = _ip;
        global.network.target_port = _port;
        global.network.is_connected = true;
        return "[网络] 连接 " + _ip + ":" + string(_port) + " 成功";
    } else {
        network_destroy(_sock);
        return "[网络] 连接失败，请检查网络设置";
    }
}

function sh_disconnect() {
    if (global.network.mode != "client") {
        return "[网络] 当前不是客户端模式";
    }
    if (global.network.client_socket != -1) {
        network_destroy(global.network.client_socket);
    }
    global.network.mode = "offline";
    global.network.client_socket = -1;
    global.network.target_ip = "";
    global.network.target_port = 27085;
    global.network.is_connected = false;
    return "[网络] 已断开连接";
}

function sh_status() {
    var _status = "=== 网络状态 ===\n";
    _status += "模式: " + global.network.mode + "\n";
    switch (global.network.mode) {
        case "server":
            _status += "服务器 IP: " + global.network.server_ip + "\n";
            _status += "端口: " + string(global.network.server_port) + "\n";
            _status += "已连接客户端: " + string(array_length(global.network.connected_clients)) + " 个\n";
            for (var i = 0; i < array_length(global.network.connected_clients); i++) {
                _status += "  #" + string(i+1) + ": " + string(global.network.connected_clients[i]) + "\n";
            }
            break;
        case "client":
            _status += "连接目标: " + global.network.target_ip + ":" + string(global.network.target_port) + "\n";
            _status += "Socket ID: " + string(global.network.client_socket) + "\n";
            _status += "连接状态: " + (global.network.is_connected ? "已连接 ✓" : "未连接 ✗") + "\n";
            break;
        case "offline":
            _status += "无活动网络连接\n";
            break;
    }
    return _status;
}

// ============================================================
// rt-shell 元数据定义（为网络命令提供自动补全与帮助信息）
// ============================================================

function meta_makeserver() {
    return {
        description: "启动 TCP 服务器（默认端口 27085）",
        arguments: ["端口（可选）"],
        suggestions: [
            ["27085", "6500", "6501"]   // 改为字符串数组
        ],
        argumentDescriptions: [
            "要监听的端口号，默认 27085"
        ],
        hidden: false,
        deferred: false
    };
}

function meta_closeserver() {
    return {
        description: "关闭服务器并断开所有客户端",
        arguments: [],
        suggestions: [],
        argumentDescriptions: [],
        hidden: false,
        deferred: false
    };
}

function meta_connectserver() {
    return {
        description: "连接到远程服务器",
        arguments: ["IP地址", "端口号"],
        suggestions:  ["27085", "6500", "6501"],   // 改为字符串数组
        argumentDescriptions: [
            "要连接的服务器 IP 地址",
            "要连接的服务器端口（默认 27085）"
        ],
        hidden: false,
        deferred: false
    };
}

function meta_disconnect() {
    return {
        description: "断开当前客户端连接",
        arguments: [],
        suggestions: [],
        argumentDescriptions: [],
        hidden: false,
        deferred: false
    };
}

function meta_status() {
    return {
        description: "显示当前网络状态",
        arguments: [],
        suggestions: [],
        argumentDescriptions: [],
        hidden: false,
        deferred: false
    };
}
