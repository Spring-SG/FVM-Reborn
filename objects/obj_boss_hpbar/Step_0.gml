// 服务端：血条数据变化时立即同步到客户端
if (global.network.mode == "server" && instance_exists(target_boss)) {
    var _hp = target_boss.hp;
    if (_hp < 0) _hp = 0;
    var _mhp = target_boss.maxhp;
    if (!variable_instance_exists(id, "prev_sync_hp")) {
        prev_sync_hp = _hp;
        prev_sync_mhp = _mhp;
    }
    if (_hp != prev_sync_hp || _mhp != prev_sync_mhp) {
        prev_sync_hp = _hp;
        prev_sync_mhp = _mhp;
        var _nid = (ds_map_exists(global.network.map_instance_id_net_id, target_boss.id))
            ? global.network.map_instance_id_net_id[? target_boss.id] : -1;
        if (_nid != -1) {
            var _json = json_stringify({ hp: _hp, maxhp: _mhp });
            var _list = global.network.connected_clients;
            for (var _i = 0; _i < array_length(_list); _i++) {
                send_message(_list[_i], MSG_MODIFY_PROP, _nid, _json);
            }
        }
    }
}
