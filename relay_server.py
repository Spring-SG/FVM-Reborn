"""
中继服务器
  1. 管理客户端 — 房间、房主/客户端角色、加入/离开
  2. 转发消息   — 房主→广播给房间所有客户端，客户端→只转给房主
  3. CHAT命令   — 解析 MSG_CHAT 中 /connectroom、/list 等命令

包格式与 GM 端一致: [u16 body_len][i32 msg_id][payload]
"""

import asyncio
import random
import struct

HOST = "0.0.0.0"
PORT = 27085

# 消息ID (与 GM 端 #macro 一致)
MSG_CHAT          = 3
MSG_PUB_INFO      = 23

# 随机名字池
NAMES = [
    "小笼包", "烧麦", "虾饺", "春卷", "汤圆", "粽子", "月饼",
    "火锅", "麻辣烫", "烤串", "炸鸡", "汉堡", "薯条", "可乐",
    "奶茶", "布丁", "果冻", "蛋糕", "饼干", "冰淇淋", "巧克力",
    "爆米花", "甜甜圈", "马卡龙", "提拉米苏", "芒果", "草莓", "西瓜",
    "菠萝", "葡萄", "柠檬", "樱桃", "蜜桃", "椰子", "榴莲",
    "年糕", "麻薯", "蛋挞", "松饼", "可颂", "吐司", "饭团",
]
NUL = b"\x00"  # GM buffer_string 需要的终止符


class Room:
    def __init__(self, rid: str):
        self.id = rid
        self.host = None          # writer | None
        self.clients = {}         # cid(int) → writer
        self.nicks = {}           # writer_id → 昵称
        self.next_cid = 1

    @property
    def member_count(self):
        return 1 + len(self.clients) if self.host else len(self.clients)

    def used_names(self) -> set:
        return set(self.nicks.values())


class Relay:
    def __init__(self):
        self.rooms: dict[str, Room] = {}
        self.sessions: dict[int, tuple[Room, int, int, str]] = {}
        # sessions: writer_id → (room, role, cid, name)

        self.commands = {
            "\\list":        ("列出房间成员", ""),
            "\\who":         ("显示自己是谁", ""),
            "\\rename":      ("修改昵称", " <新名字>"),
            "\\kick":        ("房主踢人", " <玩家名>"),
            "\\listcommand": ("列出所有命令", ""),
        }

    # ================================================================
    #  包读写 — GM buffer_string 需要 \\0 终止符
    # ================================================================
    async def read_pkt(self, reader):
        """读 [u16 len][i32 msg_id][payload]"""
        try:
            raw = await reader.readexactly(2)
            body_len = struct.unpack("<H", raw)[0]
            raw = await reader.readexactly(body_len)
            msg_id  = struct.unpack_from("<i", raw, 0)[0]
            payload = raw[4:]
            return msg_id, payload
        except asyncio.IncompleteReadError:
            return None

    def write_pkt(self, writer, msg_id: int, payload: bytes = b""):
        if writer.is_closing():
            return
        body   = struct.pack("<i", msg_id) + payload
        packet = struct.pack("<H", len(body)) + body
        writer.write(packet)

    def write_str(self, writer, msg_id: int, text: str):
        """发字符串消息，自动加 \\0"""
        self.write_pkt(writer, msg_id, text.encode() + NUL)

    async def flush(self, writer):
        try:
            await writer.drain()
        except Exception:
            pass

    # ================================================================
    #  1. 管理客户端
    # ================================================================
    def _pick_name(self, room: Room, preferred: str = "") -> str:
        used = room.used_names()
        if not preferred:
            pool = [n for n in NAMES if n not in used]
            if not pool:
                pool = [random.choice(NAMES) + "_" + str(len(used)) for _ in range(5)]
            preferred = random.choice(pool)
        name = preferred
        n = 2
        while name in used:
            name = f"{preferred}{n}"
            n += 1
        return name

    def _add_to_room(self, room: Room, writer) -> tuple[int, int, str]:
        if room.host is None:
            room.host = writer
            role, cid = 0, 0
        else:
            cid = room.next_cid
            room.next_cid += 1
            room.clients[cid] = writer
            role = 1
        name = self._pick_name(room)
        room.nicks[id(writer)] = name
        return role, cid, name

    def remove(self, writer):
        key = id(writer)
        if key not in self.sessions:
            self._close(writer)
            return

        room, role, cid, name = self.sessions.pop(key)
        room.nicks.pop(key, None)

        if role == 0:
            for c in list(room.clients.values()):
                self.write_pkt(c, MSG_PUB_INFO, b"\\host_left" + NUL)
                self._close(c)
            room.clients.clear()
            room.host = None
            del self.rooms[room.id]
            print(f"[{room.id}] 房主({name}) 离开，房间关闭")
        else:
            room.clients.pop(cid, None)
            if room.host:
                self.write_str(room.host, MSG_CHAT, f"[系统] {name} 离开")
                asyncio.ensure_future(self.flush(room.host))
            print(f"[{room.id}] {name} 离开 (剩余 {len(room.clients)} 人)")

        self._close(writer)

    def _close(self, writer):
        try:
            writer.close()
        except Exception:
            pass

    # ================================================================
    #  2. 转发消息
    # ================================================================
    async def _broadcast(self, room: Room, body: bytes):
        """房主 → 所有客户端（并行 drain）"""
        packet = struct.pack("<H", len(body)) + body
        tasks = []
        for c in list(room.clients.values()):
            c.write(packet)
            tasks.append(self.flush(c))
        if tasks:
            await asyncio.gather(*tasks, return_exceptions=True)

    async def _to_host(self, room: Room, body: bytes):
        """客户端 → 房主"""
        if room.host and not room.host.is_closing():
            packet = struct.pack("<H", len(body)) + body
            room.host.write(packet)
            await self.flush(room.host)

    # ================================================================
    #  3. CHAT 命令处理
    # ================================================================
    def _handle_cmd(self, writer, room: Room, role: int, cid: int, text: str) -> bool:
        if not text.startswith("\\"):
            return False

        parts = text.split()
        cmd = parts[0].lower()
        key = id(writer)
        name = room.nicks.get(key, "???")

        if cmd == "\\connectroom":
            return False

        # ---- \\list ----
        if cmd == "\\list":
            lines = [f"=== 房间 {room.id} ==="]
            host_name = room.nicks.get(id(room.host), "???") if room.host else "(无)"
            lines.append(f"  [房主] {host_name}")
            for cid2, cw in sorted(room.clients.items()):
                cn = room.nicks.get(id(cw), "???")
                lines.append(f"  {cn}")
            self.write_str(writer, MSG_CHAT, "\n".join(lines))
            return True

        # ---- \\who ----
        if cmd == "\\who":
            role_name = "房主" if role == 0 else "客户端"
            self.write_str(writer, MSG_CHAT,
                           f"[系统] 你是 {name} ({role_name})，房间 {room.id}")
            return True

        # ---- \\rename <新名字> ----
        if cmd == "\\rename":
            if len(parts) < 2 or parts[1].strip() == "":
                self.write_str(writer, MSG_CHAT, "[系统] 用法: /rename <新名字>")
                return True
            new_name = parts[1].strip()
            used = room.used_names()
            used.discard(name)
            if new_name in used:
                n = 2
                while f"{new_name}{n}" in used:
                    n += 1
                new_name = f"{new_name}{n}"
            room.nicks[key] = new_name
            self.write_str(writer, MSG_CHAT, f"[系统] 你已改名为 {new_name}")
            notice = f"[系统] {name} 改名为 {new_name}"
            if role == 0:
                for c in room.clients.values():
                    self.write_str(c, MSG_CHAT, notice)
            else:
                if room.host:
                    self.write_str(room.host, MSG_CHAT, notice)
            return True

        # ---- \\kick <玩家名> ----
        if cmd == "\\kick":
            if role != 0:
                self.write_str(writer, MSG_CHAT, "[系统] 只有房主可以踢人")
                return True
            if len(parts) < 2 or parts[1].strip() == "":
                self.write_str(writer, MSG_CHAT, "[系统] 用法: /kick <玩家名>")
                return True
            target_name = parts[1].strip()
            found = None
            for cid2, cw in list(room.clients.items()):
                if room.nicks.get(id(cw), "") == target_name:
                    found = (cid2, cw)
                    break
            if found is None:
                self.write_str(writer, MSG_CHAT, f"[系统] 没有叫 {target_name} 的玩家")
                return True

            t_cid, t_writer = found
            self.write_pkt(t_writer, MSG_PUB_INFO, b"\\kicked" + NUL)
            self._close(t_writer)
            room.clients.pop(t_cid, None)
            room.nicks.pop(id(t_writer), None)
            self.sessions.pop(id(t_writer), None)

            self.write_str(writer, MSG_CHAT, f"[系统] 你踢出了 {target_name}")
            notice = f"[系统] {target_name} 被房主踢出"
            for cw in room.clients.values():
                self.write_str(cw, MSG_CHAT, notice)
            return True

        # ---- \\listcommand ----
        if cmd == "\\listcommand":
            lines = ["=== 可用命令 ==="]
            for cname, (desc, usage) in self.commands.items():
                lines.append(f"  {cname}{usage} — {desc}")
            self.write_str(writer, MSG_CHAT, "\n".join(lines))
            return True

        self.write_str(writer, MSG_CHAT, f"[系统] 未知命令: {cmd}")
        return True

    # ================================================================
    #  总入口
    # ================================================================
    async def handle(self, reader, writer):
        addr = writer.get_extra_info("peername")
        print(f"[连接] {addr[0]}:{addr[1]}")

        # 首包: MSG_CHAT + /connectroom <房间ID>
        pkt = await self.read_pkt(reader)
        if pkt is None:
            self._close(writer)
            return
        msg_id, payload = pkt
        if msg_id != MSG_CHAT:
            print(f"  首包不是 MSG_CHAT (msg_id={msg_id}), 断开")
            self._close(writer)
            return
        try:
            text = payload.decode("utf-8").rstrip("\x00")
        except UnicodeDecodeError:
            self._close(writer)
            return
        if not text.startswith("/connectroom "):
            print(f"  首包不是 /connectroom: {text}")
            self._close(writer)
            return

        room_id = text.split(" ", 1)[1].strip()
        if room_id not in self.rooms:
            self.rooms[room_id] = Room(room_id)
        room = self.rooms[room_id]
        role, cid, name = self._add_to_room(room, writer)
        self.sessions[id(writer)] = (room, role, cid, name)

        role_str = "\\modserver" if role == 0 else "\\modclient"
        self.write_pkt(writer, MSG_PUB_INFO, role_str.encode() + NUL)
        await self.flush(writer)

        print(f"  [{room.id}] {name} 加入 ({room.member_count} 人)")

        if role == 1 and room.host:
            self.write_str(room.host, MSG_CHAT, f"[系统] {name} 加入")
            await self.flush(room.host)

        try:
            while True:
                pkt = await self.read_pkt(reader)
                if pkt is None:
                    break
                msg_id, payload = pkt
                body = struct.pack("<i", msg_id) + payload

                if msg_id == MSG_CHAT:
                    try:
                        txt = payload.decode("utf-8").rstrip("\x00")
                    except UnicodeDecodeError:
                        txt = ""
                    # 去掉 GM 端拼入的 "say " 前缀
                    if txt.startswith("say "):
                        txt = txt[4:]
                    # 命令拦截
                    if self._handle_cmd(writer, room, role, cid, txt):
                        await self.flush(writer)
                        continue
                    # 普通聊天 → "名称: xxx"
                    txt = name + ": " + txt
                    body = struct.pack("<i", msg_id) + txt.encode() + NUL

                if role == 0:
                    await self._broadcast(room, body)
                else:
                    await self._to_host(room, body)
        except (ConnectionResetError, ConnectionAbortedError, BrokenPipeError):
            pass  # 客户端断开，正常清理
        finally:
            self.remove(writer)


async def main():
    relay = Relay()
    srv = await asyncio.start_server(relay.handle, HOST, PORT)
    print(f"中继启动: {HOST}:{PORT}")
    async with srv:
        await srv.serve_forever()

if __name__ == "__main__":
    asyncio.run(main())
