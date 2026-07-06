// relay_server.cpp — C++ 中继服务器
// 编译 (MinGW):  g++ -o relay_server.exe relay_server.cpp -lws2_32 -std=c++17 -O2
// 编译 (MSVC):   cl /EHsc /std:c++17 /O2 relay_server.cpp ws2_32.lib
// 用法: relay_server.exe [端口]  默认端口 27085

#ifdef _WIN32
    #ifndef _WIN32_WINNT
        #define _WIN32_WINNT 0x0600
    #endif
    #include <winsock2.h>
    #include <ws2tcpip.h>
    #pragma comment(lib, "ws2_32.lib")
    using socklen_t = int;
    #define MSG_NOSIGNAL 0
#else
    #include <sys/socket.h>
    #include <netinet/in.h>
    #include <arpa/inet.h>
    #include <unistd.h>
    #include <fcntl.h>
    #include <sys/select.h>
    #define SOCKET int
    #define INVALID_SOCKET (-1)
    #define SOCKET_ERROR   (-1)
    #define closesocket    close
#endif

#include <cstdint>
#include <cstring>
#include <ctime>
#include <algorithm>
#include <chrono>
#include <iostream>
#include <map>
#include <mutex>
#include <random>
#include <set>
#include <sstream>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>

// ================================================================
//  消息ID (与 GM 端一致)
// ================================================================
enum : int32_t {
    MSG_CHAT          = 3,
    MSG_PUB_INFO      = 23,
    MSG_REQUEST_FILE  = 26,
    MSG_TRANSFER_FILE = 27,
};

// ================================================================
//  随机名字池
// ================================================================
const std::vector<std::string> NAMES = {
    "小笼包","烧麦","虾饺","春卷","汤圆","粽子","月饼",
    "火锅","麻辣烫","烤串","炸鸡","汉堡","薯条","可乐",
    "奶茶","布丁","果冻","蛋糕","饼干","冰淇淋","巧克力",
    "爆米花","甜甜圈","马卡龙","提拉米苏","芒果","草莓","西瓜",
    "菠萝","葡萄","柠檬","樱桃","蜜桃","椰子","榴莲",
    "年糕","麻薯","蛋挞","松饼","可颂","吐司","饭团",
};

// ================================================================
//  socket 工具
// ================================================================
bool set_nonblock(SOCKET s) {
#ifdef _WIN32
    u_long mode = 1;
    return ioctlsocket(s, FIONBIO, &mode) == 0;
#else
    int flags = fcntl(s, F_GETFL, 0);
    return fcntl(s, F_SETFL, flags | O_NONBLOCK) != -1;
#endif
}

void init_network() {
#ifdef _WIN32
    WSADATA wsa;
    WSAStartup(MAKEWORD(2,2), &wsa);
#endif
}

void cleanup_network() {
#ifdef _WIN32
    WSACleanup();
#endif
}

// ================================================================
//  读/写工具 — 包格式: [u32 body_len][i32 msg_id][payload]
// ================================================================
bool send_all(SOCKET s, const void* data, size_t len) {
    size_t sent = 0;
    while (sent < len) {
        int n = ::send(s, (const char*)data + sent, (int)(len - sent), MSG_NOSIGNAL);
        if (n <= 0) return false;
        sent += n;
    }
    return true;
}

bool recv_all(SOCKET s, void* buf, size_t len) {
    size_t got = 0;
    while (got < len) {
        int n = ::recv(s, (char*)buf + got, (int)(len - got), 0);
        if (n <= 0) return false;
        got += n;
    }
    return true;
}

// 读一个 NUL 结尾的字符串
std::string read_str(const uint8_t* data, int& off) {
    const char* start = (const char*)data + off;
    const char* end   = (const char*)memchr(start, 0, 65536);
    if (!end) { off = (int)strlen(start); return start; }
    off = (int)(end - start) + 1 + (off - off);  // advance past start offset
    return std::string(start, end - start);
}

// 构建 NUL 结尾字符串
std::vector<uint8_t> build_str(const std::string& s) {
    std::vector<uint8_t> out(s.size() + 1);
    memcpy(out.data(), s.c_str(), s.size() + 1);
    return out;
}

std::vector<uint8_t> build_str(const std::string& a, const std::string& b) {
    std::vector<uint8_t> out(a.size() + 1 + b.size() + 1);
    memcpy(out.data(), a.c_str(), a.size() + 1);
    memcpy(out.data() + a.size() + 1, b.c_str(), b.size() + 1);
    return out;
}

// 发送包
bool write_pkt(SOCKET s, int32_t msg_id, const void* payload = nullptr, int payload_len = 0) {
    int body_len = 4 + payload_len;
    std::vector<uint8_t> pkt(4 + body_len);
    memcpy(pkt.data(), &body_len, 4);
    memcpy(pkt.data() + 4, &msg_id, 4);
    if (payload && payload_len > 0)
        memcpy(pkt.data() + 8, payload, payload_len);
    return send_all(s, pkt.data(), pkt.size());
}

bool write_str(SOCKET s, int32_t msg_id, const std::string& text) {
    std::vector<uint8_t> payload(text.size() + 1);
    memcpy(payload.data(), text.c_str(), text.size() + 1);
    return write_pkt(s, msg_id, payload.data(), (int)payload.size());
}

// ================================================================
//  数据结构
// ================================================================

struct Client {
    SOCKET sock;
    int cid;         // 0 = 房主, >0 = 客户端编号
    int role;        // 0 = 房主, 1 = 客户端
    std::string name;
};

struct Room {
    std::string id;
    SOCKET host = INVALID_SOCKET;
    std::map<int, SOCKET> clients;   // cid → sock
    std::map<SOCKET, std::string> nicks;
    int next_cid = 1;
    std::string state = "lobby";
    std::string data;
    double created_at = 0;
    double battle_started_at = 0;
    std::unordered_map<std::string, std::vector<uint8_t>> file_cache;
    std::unordered_map<std::string, std::vector<std::pair<SOCKET, std::string>>> file_pending;
    std::unordered_map<std::string, std::string> msgs;  // name → 最新消息

    int member_count() const {
        int n = (host != INVALID_SOCKET) ? 1 : 0;
        return n + (int)clients.size();
    }

    std::set<std::string> used_names() const {
        std::set<std::string> s;
        for (auto& kv : nicks) s.insert(kv.second);
        return s;
    }
};

// ================================================================
//  全局状态
// ================================================================
struct Relay {
    std::mutex mtx;
    std::unordered_map<std::string, Room> rooms;
    std::unordered_map<SOCKET, std::string> session_room;   // sock → room_id
    std::unordered_map<SOCKET, int>      session_role;      // sock → role
    std::unordered_map<SOCKET, int>      session_cid;       // sock → cid
    std::mt19937 rng{ std::random_device{}() };
} g_relay;

int g_max_members = 8;

// ================================================================
//  名字 / 房间工具
// ================================================================
std::string pick_name(Room& room, const std::string& preferred = "") {
    auto used = room.used_names();
    if (preferred.empty()) {
        std::vector<std::string> pool;
        for (auto& n : NAMES) if (!used.count(n)) pool.push_back(n);
        if (pool.empty()) {
            std::uniform_int_distribution<int> d(0, (int)NAMES.size()-1);
            for (int i = 0; i < 5; i++)
                pool.push_back(NAMES[d(g_relay.rng)] + "_" + std::to_string(used.size()));
        }
        std::uniform_int_distribution<int> d(0, (int)pool.size()-1);
        std::string name = pool[d(g_relay.rng)];
        int n = 2;
        while (used.count(name)) { name = pool[0] + std::to_string(n); n++; }
        return name;
    }
    std::string name = preferred;
    int n = 2;
    while (used.count(name)) { name = preferred + std::to_string(n); n++; }
    return name;
}

void add_to_room(Room& room, SOCKET sock, Client& cli) {
    if (room.host == INVALID_SOCKET) {
        room.host = sock;
        cli.role = 0;
        cli.cid  = 0;
    } else {
        cli.cid  = room.next_cid++;
        cli.role = 1;
        room.clients[cli.cid] = sock;
    }
    cli.name = pick_name(room);
    room.nicks[sock] = cli.name;
}

void close_sock(SOCKET s) {
    shutdown(s, 2);
    closesocket(s);
}

// ================================================================
//  room info
// ================================================================
std::string build_room_info(Room& room) {
    std::string members = "{";
    if (room.host != INVALID_SOCKET) {
        auto it = room.nicks.find(room.host);
        std::string name = (it != room.nicks.end()) ? it->second : "???";
        name = name.substr(0, 20);
        auto mit = room.msgs.find(name);
        std::string msg = (mit != room.msgs.end()) ? mit->second : "";
        members += "\"" + name + "\":\"" + msg + "\"";
    }
    for (auto& kv : room.clients) {
        auto it = room.nicks.find(kv.second);
        std::string name = (it != room.nicks.end()) ? it->second : "???";
        name = name.substr(0, 20);
        members += (members.size() > 1 ? "," : "") + std::string("\"") + name + "\":\"";
        auto mit = room.msgs.find(name);
        if (mit != room.msgs.end()) members += mit->second;
        members += "\"";
    }
    members += "}";
    std::string json = "{\"room\":\"" + room.id + "\",\"members\":" + members + "}";
    return "\\roominfo " + json;
}

void sync_room_info(Room& room) {
    std::string info = build_room_info(room);
    if (room.host != INVALID_SOCKET)
        write_str(room.host, MSG_PUB_INFO, info);
    for (auto& kv : room.clients)
        write_str(kv.second, MSG_PUB_INFO, info);
}

// ================================================================
//  文件缓存
// ================================================================
void handle_request_file(Room& room, SOCKET sock, const std::vector<uint8_t>& payload) {
    int off = 0;
    std::string filename = read_str(payload.data(), off);
    std::string purpose  = read_str(payload.data(), off);
    auto it = room.nicks.find(sock);
    std::string name = (it != room.nicks.end()) ? it->second : "???";

    auto cit = room.file_cache.find(filename);
    if (cit != room.file_cache.end()) {
        auto& data = cit->second;
        printf("[文件] 缓存命中 → %s: [%s] purpose=[%s] (%zu bytes)\n", name.c_str(), filename.c_str(), purpose.c_str(), data.size());
        auto str = build_str(filename, purpose);
        std::vector<uint8_t> body(4 + str.size() + 4 + data.size());
        int32_t msg = MSG_TRANSFER_FILE;
        memcpy(body.data(), &msg, 4);
        memcpy(body.data() + 4, str.data(), str.size());
        int32_t sz = (int32_t)data.size();
        memcpy(body.data() + 4 + str.size(), &sz, 4);
        memcpy(body.data() + 4 + str.size() + 4, data.data(), data.size());
        write_pkt(sock, MSG_TRANSFER_FILE, body.data() + 4, (int)body.size() - 4);
        return;
    }

    auto pit = room.file_pending.find(filename);
    if (pit != room.file_pending.end()) {
        printf("[文件] 排队等待 → %s: [%s] (已有 %zu 人在等)\n", name.c_str(), filename.c_str(), pit->second.size());
        pit->second.push_back({sock, purpose});
        return;
    }
    printf("[文件] 向房主请求 → %s: [%s]\n", name.c_str(), filename.c_str());
    room.file_pending[filename] = {{sock, purpose}};
    // 转发 MSG_REQUEST_FILE 给房主
    int32_t msg = MSG_REQUEST_FILE;
    std::vector<uint8_t> fwd(4 + payload.size());
    memcpy(fwd.data(), &msg, 4);
    memcpy(fwd.data() + 4, payload.data(), payload.size());
    if (room.host != INVALID_SOCKET)
        write_pkt(room.host, MSG_REQUEST_FILE, payload.data(), (int)payload.size());
}

void handle_transfer_file(Room& room, const std::vector<uint8_t>& payload) {
    int off = 0;
    std::string filename = read_str(payload.data(), off);
    std::string purpose  = read_str(payload.data(), off);
    int32_t size = 0;
    memcpy(&size, payload.data() + off, 4);
    off += 4;
    std::vector<uint8_t> data(payload.begin() + off, payload.begin() + off + size);
    room.file_cache[filename] = data;

    auto waiters = std::move(room.file_pending[filename]);
    room.file_pending.erase(filename);
    printf("[文件] 房主返回 → [%s] (%d bytes) → 发给 %zu 人\n", filename.c_str(), size, waiters.size());

    for (auto& w : waiters) {
        SOCKET ws = w.first;
        auto str = build_str(filename, w.second);
        std::vector<uint8_t> body(4 + str.size() + 4 + data.size());
        int32_t msg = MSG_TRANSFER_FILE;
        memcpy(body.data(), &msg, 4);
        memcpy(body.data() + 4, str.data(), str.size());
        int32_t sz = (int32_t)data.size();
        memcpy(body.data() + 4 + str.size(), &sz, 4);
        memcpy(body.data() + 4 + str.size() + 4, data.data(), data.size());
        write_pkt(ws, MSG_TRANSFER_FILE, body.data() + 4, (int)body.size() - 4);
    }
}

// ================================================================
//  CHAT 命令处理
// ================================================================
bool handle_cmd(SOCKET sock, Room& room, int role, const std::string& text) {
    if (text.empty() || text[0] != '\\') return false;

    auto pos = text.find(' ');
    std::string cmd = text.substr(0, pos);
    std::string rest = (pos != std::string::npos) ? text.substr(pos + 1) : "";
    auto it = room.nicks.find(sock);
    std::string name = (it != room.nicks.end()) ? it->second : "???";

    if (cmd == "\\connectroom") return false;

    // \\syncroom
    if (cmd == "\\syncroom" && role == 0) {
        room.data = rest;
        room.state = "lobby";
        return true;
    }
    // \\list
    if (cmd == "\\list") {
        std::string out = "=== 房间 " + room.id + " ===\n";
        auto hit = room.nicks.find(room.host);
        out += "  [房主] " + ((hit != room.nicks.end()) ? hit->second : "(无)") + "\n";
        for (auto& kv : room.clients) {
            auto cit = room.nicks.find(kv.second);
            out += "  " + ((cit != room.nicks.end()) ? cit->second : "???") + "\n";
        }
        write_str(sock, MSG_CHAT, out);
        return true;
    }
    // \\who
    if (cmd == "\\who") {
        std::string rn = (role == 0) ? "房主" : "客户端";
        write_str(sock, MSG_CHAT, "[系统] 你是 " + name + " (" + rn + ")，房间 " + room.id);
        return true;
    }
    // \\rename
    if (cmd == "\\rename") {
        if (rest.empty()) {
            write_str(sock, MSG_CHAT, "[系统] 用法: /rename <新名字>");
            return true;
        }
        std::string new_name = rest;
        auto used = room.used_names();
        used.erase(name);
        if (used.count(new_name)) {
            int n = 2;
            while (used.count(new_name + std::to_string(n))) n++;
            new_name = new_name + std::to_string(n);
        }
        room.nicks[sock] = new_name;
        write_str(sock, MSG_CHAT, "[系统] 你已改名为 " + new_name);
        std::string notice = "[系统] " + name + " 改名为 " + new_name;
        if (role == 0) {
            for (auto& kv : room.clients) write_str(kv.second, MSG_CHAT, notice);
        } else {
            if (room.host != INVALID_SOCKET) write_str(room.host, MSG_CHAT, notice);
        }
        sync_room_info(room);
        return true;
    }
    // \\kick
    if (cmd == "\\kick") {
        if (role != 0) { write_str(sock, MSG_CHAT, "[系统] 只有房主可以踢人"); return true; }
        if (rest.empty()) { write_str(sock, MSG_CHAT, "[系统] 用法: /kick <玩家名>"); return true; }
        SOCKET target = INVALID_SOCKET;
        int target_cid = -1;
        for (auto& kv : room.clients) {
            auto nit = room.nicks.find(kv.second);
            if (nit != room.nicks.end() && nit->second == rest) {
                target = kv.second; target_cid = kv.first; break;
            }
        }
        if (target == INVALID_SOCKET) {
            write_str(sock, MSG_CHAT, "[系统] 没有叫 " + rest + " 的玩家");
            return true;
        }
        write_str(target, MSG_PUB_INFO, "\\kicked");
        close_sock(target);
        room.clients.erase(target_cid);
        room.nicks.erase(target);
        {
            std::lock_guard<std::mutex> lk(g_relay.mtx);
            g_relay.session_room.erase(target);
            g_relay.session_role.erase(target);
            g_relay.session_cid.erase(target);
        }
        write_str(sock, MSG_CHAT, "[系统] 你踢出了 " + rest);
        std::string notice = "[系统] " + rest + " 被房主踢出";
        for (auto& kv : room.clients) write_str(kv.second, MSG_CHAT, notice);
        sync_room_info(room);
        return true;
    }
    // \\listroom
    if (cmd == "\\listroom") {
        std::lock_guard<std::mutex> lk(g_relay.mtx);
        if (g_relay.rooms.empty()) {
            write_str(sock, MSG_CHAT, "[系统] 当前没有房间");
        } else {
            std::string out = "=== 房间列表 ===";
            for (auto& kv : g_relay.rooms)
                out += "\n  " + kv.first + " - " + std::to_string(kv.second.member_count()) + " 人";
            write_str(sock, MSG_CHAT, out);
        }
        return true;
    }
    // \\listcommand
    if (cmd == "\\listcommand") {
        write_str(sock, MSG_CHAT,
            "=== 可用命令 ===\n"
            "  \\list         - 列出房间成员\n"
            "  \\who          - 显示自己是谁\n"
            "  \\rename <名>  - 修改昵称\n"
            "  \\kick <名>    - 房主踢人\n"
            "  \\listroom     - 列出所有房间\n"
            "  \\listcommand  - 列出所有命令");
        return true;
    }

    write_str(sock, MSG_CHAT, "[系统] 未知命令: " + cmd);
    return true;
}

// ================================================================
//  广播/转发
// ================================================================
void broadcast(Room& room, const std::vector<uint8_t>& body) {
    for (auto& kv : room.clients)
        write_pkt(kv.second, *(int32_t*)body.data(), body.data() + 4, (int)body.size() - 4);
}

void to_host(Room& room, const std::vector<uint8_t>& body) {
    if (room.host != INVALID_SOCKET)
        write_pkt(room.host, *(int32_t*)body.data(), body.data() + 4, (int)body.size() - 4);
}

void broadcast_except(Room& room, const std::vector<uint8_t>& body, SOCKET exclude) {
    if (room.host != INVALID_SOCKET && room.host != exclude)
        write_pkt(room.host, *(int32_t*)body.data(), body.data() + 4, (int)body.size() - 4);
    for (auto& kv : room.clients)
        if (kv.second != exclude)
            write_pkt(kv.second, *(int32_t*)body.data(), body.data() + 4, (int)body.size() - 4);
}

void remove_client(SOCKET sock) {
    std::lock_guard<std::mutex> lk(g_relay.mtx);
    auto rit = g_relay.session_room.find(sock);
    if (rit == g_relay.session_room.end()) { close_sock(sock); return; }

    std::string room_id = rit->second;
    int role = g_relay.session_role[sock];
    auto room_it = g_relay.rooms.find(room_id);
    if (room_it == g_relay.rooms.end()) { close_sock(sock); return; }
    Room& room = room_it->second;
    auto nit = room.nicks.find(sock);
    std::string name = (nit != room.nicks.end()) ? nit->second : "???";

    if (role == 0) {
        // 房主离开 → 关闭房间
        for (auto& kv : room.clients) {
            write_str(kv.second, MSG_PUB_INFO, "\\host_left");
            close_sock(kv.second);
            g_relay.session_room.erase(kv.second);
            g_relay.session_role.erase(kv.second);
            g_relay.session_cid.erase(kv.second);
        }
        room.clients.clear();
        room.host = INVALID_SOCKET;
        room.nicks.clear();
        g_relay.rooms.erase(room_id);
        printf("[%s] 房主(%s) 离开，房间关闭\n", room_id.c_str(), name.c_str());
    } else {
        int cid = g_relay.session_cid[sock];
        room.clients.erase(cid);
        room.nicks.erase(sock);
        if (room.host != INVALID_SOCKET)
            write_str(room.host, MSG_CHAT, "[系统] " + name + " 离开");
        printf("[%s] %s 离开 (剩余 %d 人)\n", room_id.c_str(), name.c_str(), room.member_count());
        sync_room_info(room);
    }

    g_relay.session_room.erase(sock);
    g_relay.session_role.erase(sock);
    g_relay.session_cid.erase(sock);
    close_sock(sock);
}

// ================================================================
//  客户端处理线程
// ================================================================
void handle_client(SOCKET sock) {
    // 读首包: [u32 len][i32 MSG_CHAT][payload]
    uint32_t len;
    if (!recv_all(sock, &len, 4)) { close_sock(sock); return; }
    std::vector<uint8_t> body(len);
    if (!recv_all(sock, body.data(), len)) { close_sock(sock); return; }

    int32_t msg_id;
    memcpy(&msg_id, body.data(), 4);
    if (msg_id != MSG_CHAT) { printf("  首包不是 MSG_CHAT\n"); close_sock(sock); return; }

    std::string text((char*)body.data() + 4, len - 4);
    if (!text.empty() && text.back() == 0) text.pop_back();
    if (text.find("/connectroom ") != 0) {
        printf("  首包不是 /connectroom: %s\n", text.c_str());
        close_sock(sock); return;
    }

    std::string room_id = text.substr(14);
    // 去掉首尾空格
    while (!room_id.empty() && room_id[0] == ' ') room_id.erase(0, 1);
    while (!room_id.empty() && room_id.back() == ' ') room_id.pop_back();

    bool is_new_room = false;
    {
        std::lock_guard<std::mutex> lk(g_relay.mtx);
        if (g_relay.rooms.find(room_id) == g_relay.rooms.end()) {
            g_relay.rooms[room_id] = Room{};
            g_relay.rooms[room_id].id = room_id;
            g_relay.rooms[room_id].created_at =
                std::chrono::duration<double>(std::chrono::system_clock::now().time_since_epoch()).count();
        }
    }

    Room* room_ptr = nullptr;
    {
        std::lock_guard<std::mutex> lk(g_relay.mtx);
        room_ptr = &g_relay.rooms[room_id];
    }
    Room& room = *room_ptr;

    // 战斗中不能加入
    if (room.host != INVALID_SOCKET && room.state == "battle") {
        write_str(sock, MSG_CHAT, "[系统] 房间战斗中，无法加入");
        write_str(sock, MSG_PUB_INFO, "\\kicked");
        close_sock(sock);
        return;
    }

    // 房间已满
    if (room.host != INVALID_SOCKET && room.member_count() >= g_max_members) {
        printf("  [%s] 房间已满 (%d/%d)，拒绝加入\n", room.id.c_str(), room.member_count(), g_max_members);
        write_str(sock, MSG_CHAT, "[系统] 房间已满 (" + std::to_string(g_max_members) + "人)，无法加入");
        write_str(sock, MSG_PUB_INFO, "\\kicked");
        close_sock(sock);
        return;
    }

    Client cli;
    {
        std::lock_guard<std::mutex> lk(g_relay.mtx);
        add_to_room(room, sock, cli);
        g_relay.session_room[sock] = room_id;
        g_relay.session_role[sock] = cli.role;
        g_relay.session_cid[sock]  = cli.cid;
    }

    // 告诉客户端身份
    write_str(sock, MSG_PUB_INFO, (cli.role == 0) ? "\\modserver" : "\\modclient");

    if (cli.role == 0) {
        write_str(sock, MSG_CHAT,
            "[系统] 你已创建房间 " + room.id + "\n"
            "[系统] 你的名字是 " + cli.name + "，可使用 \\listcommand 查看命令");
    } else {
        write_str(sock, MSG_CHAT,
            "[系统] 你已加入房间 " + room.id + "\n"
            "[系统] 你的名字是 " + cli.name + "，可使用 \\listcommand 查看命令，或等待房主操作");
        if (!room.data.empty())
            write_pkt(sock, 13, room.data.c_str(), (int)room.data.size() + 1);
    }
    write_str(sock, MSG_CHAT, "[系统] 输入文字即可聊天");

    printf("  [%s] %s 加入 (%d 人)\n", room.id.c_str(), cli.name.c_str(), room.member_count());

    if (cli.role == 1 && room.host != INVALID_SOCKET)
        write_str(room.host, MSG_CHAT, "[系统] " + cli.name + " 加入");

    sync_room_info(room);

    // ================================================================
    //  消息循环
    // ================================================================
    fd_set readfds;
    timeval tv{1, 0};   // 1秒超时

    while (true) {
        FD_ZERO(&readfds);
        FD_SET(sock, &readfds);
        int ret = select(0, &readfds, nullptr, nullptr, &tv);
        if (ret < 0) break;
        if (ret == 0) { tv = {1, 0}; continue; }
        if (!FD_ISSET(sock, &readfds)) { tv = {1, 0}; continue; }

        uint32_t pkt_len = 0;
        if (!recv_all(sock, &pkt_len, 4)) break;
        std::vector<uint8_t> pkt_body(pkt_len);
        if (!recv_all(sock, pkt_body.data(), pkt_len)) break;
        tv = {1, 0};

        int32_t mid;
        memcpy(&mid, pkt_body.data(), 4);

        // 检查房间是否存在
        {
            std::lock_guard<std::mutex> lk(g_relay.mtx);
            if (g_relay.rooms.find(room_id) == g_relay.rooms.end()) break;
        }

        if (mid == MSG_CHAT) {
            std::string txt((char*)pkt_body.data() + 4, pkt_len - 4);
            if (!txt.empty() && txt.back() == 0) txt.pop_back();
            // 去掉 "say " 前缀
            if (txt.find("say ") == 0) txt = txt.substr(4);

            if (handle_cmd(sock, room, cli.role, txt)) continue;

            if (txt.find("[系统]") != 0) {
                bool already = false;
                auto names = room.used_names();
                for (auto& n : names) {
                    if (txt.find(n + ": ") == 0) { already = true; break; }
                }
                if (!already) {
                    room.msgs[cli.name] = txt.substr(0, 20);
                    sync_room_info(room);
                    txt = cli.name + ": " + txt;
                }
            }
            // 重新打包
            pkt_body.clear();
            pkt_body.resize(4 + txt.size() + 1);
            memcpy(pkt_body.data(), &mid, 4);
            memcpy(pkt_body.data() + 4, txt.c_str(), txt.size() + 1);
        }

        // 监控房间状态
        if (mid == 13 && cli.role == 0) {  // MSG_ENTER_ROOM_READY
            room.data = std::string((char*)pkt_body.data() + 4, pkt_len - 4);
            room.state = "lobby";
            room.file_cache.clear();
            room.file_pending.clear();
        } else if (mid == 12) {  // MSG_START_BATTLE
            room.state = "battle";
            room.battle_started_at =
                std::chrono::duration<double>(std::chrono::system_clock::now().time_since_epoch()).count();
        } else if (mid == 19) {  // MSG_SERVER_ACTION
            if (pkt_len > 4 && pkt_body[4] == 4) room.state = "lobby";
        }

        // 文件请求/传输
        if (mid == MSG_REQUEST_FILE && cli.role == 1) {
            std::vector<uint8_t> pl(pkt_body.begin() + 4, pkt_body.end());
            handle_request_file(room, sock, pl);
            continue;
        }
        if (mid == MSG_TRANSFER_FILE && cli.role == 0) {
            std::vector<uint8_t> pl(pkt_body.begin() + 4, pkt_body.end());
            handle_transfer_file(room, pl);
            continue;
        }

        if (cli.role == 0)
            broadcast(room, pkt_body);
        else
            to_host(room, pkt_body);
    }

    remove_client(sock);
}

// ================================================================
//  定时清理线程
// ================================================================
void cleanup_loop() {
    while (true) {
        std::this_thread::sleep_for(std::chrono::minutes(30));
        double now = std::chrono::duration<double>(
            std::chrono::system_clock::now().time_since_epoch()).count();
        std::lock_guard<std::mutex> lk(g_relay.mtx);

        std::vector<std::string> to_remove;
        for (auto& kv : g_relay.rooms) {
            auto& room = kv.second;
            double idle_hours = (now - room.created_at) / 3600.0;
            if (room.state == "battle" && room.battle_started_at > 0) {
                double battle_hours = (now - room.battle_started_at) / 3600.0;
                if (battle_hours > 2.0) {
                    printf("[清理] 房间 %s 战斗持续 %.1fh，强制关闭\n", kv.first.c_str(), battle_hours);
                    to_remove.push_back(kv.first);
                }
            } else if (room.state != "battle") {
                if (idle_hours > 2.0) {
                    printf("[清理] 房间 %s 闲置 %.1fh 未开战，强制关闭\n", kv.first.c_str(), idle_hours);
                    to_remove.push_back(kv.first);
                }
            }
        }
        for (auto& rid : to_remove) {
            auto& room = g_relay.rooms[rid];
            if (room.host != INVALID_SOCKET) {
                write_str(room.host, MSG_PUB_INFO, "\\kicked");
                close_sock(room.host);
                g_relay.session_room.erase(room.host);
                g_relay.session_role.erase(room.host);
                g_relay.session_cid.erase(room.host);
            }
            for (auto& kv : room.clients) {
                write_str(kv.second, MSG_PUB_INFO, "\\kicked");
                close_sock(kv.second);
                g_relay.session_room.erase(kv.second);
                g_relay.session_role.erase(kv.second);
                g_relay.session_cid.erase(kv.second);
            }
            room.clients.clear();
            room.nicks.clear();
            room.host = INVALID_SOCKET;
            g_relay.rooms.erase(rid);
        }
        if (!to_remove.empty())
            printf("[清理] 本轮清理了 %zu 个房间\n", to_remove.size());
    }
}

// ================================================================
//  main
// ================================================================
int main(int argc, char* argv[]) {
#ifdef _WIN32
    SetConsoleOutputCP(65001);  // UTF-8 控制台输出
    SetConsoleCP(65001);        // UTF-8 控制台输入
#endif
    init_network();

    if (argc > 1 && (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)) {
        printf("FVM 中继服务器\n");
        printf("用法: relay_server.exe [--port <端口>] [--max-members <人数>]\n");
        printf("  --port, -p       监听端口，默认 27085，被占用则递增尝试\n");
        printf("  --max-members, -m 房间最大人数，默认 8，最少 2\n");
        printf("  --help, -h       显示帮助\n");
        printf("示例: relay_server.exe --port 27085 --max-members 4\n");
        return 0;
    }

    int start_port = 27085;
    int max_members = 8;
    for (int i = 1; i < argc; i++) {
        if ((strcmp(argv[i], "--port") == 0 || strcmp(argv[i], "-p") == 0) && i + 1 < argc) {
            start_port = atoi(argv[++i]);
        } else if ((strcmp(argv[i], "--max-members") == 0 || strcmp(argv[i], "-m") == 0) && i + 1 < argc) {
            max_members = atoi(argv[++i]);
        }
    }
    if (start_port <= 0 || start_port > 65535) { printf("端口无效\n"); return 1; }
    if (max_members < 2) { printf("人数上限至少为2\n"); return 1; }
    g_max_members = max_members;

    SOCKET srv = INVALID_SOCKET;
    int port = start_port;
    for (int tries = 0; tries < 100; tries++, port++) {
        if (port > 65535) port = 1024;
        srv = socket(AF_INET, SOCK_STREAM, 0);
        if (srv == INVALID_SOCKET) { printf("socket 失败\n"); return 1; }

        int reuse = 1;
        setsockopt(srv, SOL_SOCKET, SO_REUSEADDR, (const char*)&reuse, sizeof(reuse));

        sockaddr_in addr{};
        addr.sin_family = AF_INET;
        addr.sin_addr.s_addr = INADDR_ANY;
        addr.sin_port = htons((uint16_t)port);

        if (bind(srv, (sockaddr*)&addr, sizeof(addr)) == 0) {
            if (listen(srv, 32) == 0) break;  // 成功
            printf("[%d] listen 失败，尝试下一个...\n", port);
        }
        closesocket(srv);
        srv = INVALID_SOCKET;
    }

    if (srv == INVALID_SOCKET) {
        printf("尝试了 100 个端口（%d ~ %d），全部失败，退出\n", start_port, port - 1);
        return 1;
    }

    printf("中继启动: 0.0.0.0:%d  最大人数: %d\n", port, max_members);

    std::thread(cleanup_loop).detach();

    while (true) {
        sockaddr_in cli_addr{};
        socklen_t cli_len = sizeof(cli_addr);
        SOCKET cli = accept(srv, (sockaddr*)&cli_addr, &cli_len);
        if (cli == INVALID_SOCKET) continue;

        printf("[连接] %s:%d\n", inet_ntoa(cli_addr.sin_addr), ntohs(cli_addr.sin_port));

        std::thread(handle_client, cli).detach();
    }

    closesocket(srv);
    cleanup_network();
    return 0;
}
