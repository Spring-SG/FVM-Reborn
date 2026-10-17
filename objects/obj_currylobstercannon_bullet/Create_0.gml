image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

state = "start"
target_col = -1
target_row = -1
b_shape = 0

damage = 70
timer = 0

function find_priority_enemy() {
    // 与 obj_curry_lobster_cannon 共享每帧缓存。
    //   只缓存**格子坐标**，不再缓存实例 id —— 敌人可能在同一帧里被别的子弹打死，
    //   存 id 之后再读 .grid_col / .hp 就会报 "Unable to find instance for object index N"
    if (!variable_global_exists("_curry_cannon_scan_frame")) {
        global._curry_cannon_scan_frame = -1;
        global._curry_cannon_col = -1;
        global._curry_cannon_row = -1;
        global._curry_cannon_alive = array_create(global.grid_cols * global.grid_rows, false);
    }
    if (global._curry_cannon_scan_frame != obj_battle.battle_time) {
        global._curry_cannon_scan_frame = obj_battle.battle_time;
        global._curry_cannon_col = -1;
        global._curry_cannon_row = -1;
        for (var _i = 0; _i < array_length(global._curry_cannon_alive); _i++) {
            global._curry_cannon_alive[_i] = false;
        }
        var _min_x = room_width; // 初始化为房间宽度
        var _max_hp = 0;
    
	    // 检查右边一格内是否有敌人（假设一格为80像素）
	    with (obj_enemy_parent) {
	        if (hp > 0 && can_hit("track", target_type) && y > 0) { // 只考虑存活的敌人
	            // 记录「这一格还有可打的敌人」，炮弹靠它判断当前目标格是否已经失效
	            var _idx = grid_row * global.grid_cols + grid_col;
	            if (_idx >= 0 && _idx < array_length(global._curry_cannon_alive)) {
	                global._curry_cannon_alive[_idx] = true;
	            }
	            // 同时寻找最左侧且最大生命值最高的敌人
	            if (maxhp > _max_hp || (x < _min_x && maxhp == _max_hp)) {
	                _min_x = x;
	                _max_hp = maxhp;
	                global._curry_cannon_col = grid_col;
	                global._curry_cannon_row = grid_row;
	            }
	        }
	    }
    }
    // 返回目标**格子**（找不到返回 noone）
    if (global._curry_cannon_col < 0 || global._curry_cannon_row < 0) return noone;
    return { col: global._curry_cannon_col, row: global._curry_cannon_row };
}