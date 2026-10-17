if !obj_readyroom_manager.is_submenu_open{
	global.audio.play(snd_button,0,0)
	var _rm = obj_readyroom_manager
	// 清空前：当前页每个占用的槽位生成一条飞回卡池的动画（出发 = 槽位，落点 = 该卡在卡池里的格子）
	// 只做当前页的 11 格：其它页的卡本来就不在画面上，直接消失看不出差别
	var _first = _rm.deck_first_slot_index
	var _n = 0
	for (var _i = _first; _i < _first + 11; _i++){
		if _i >= deck_slot_max() break
		if !deck_slot_is_empty(_i){
			var _entry = global.selected_deck[| _i]
			var _cid   = _entry[? "card_id"]
			var _spr   = _entry[? "data"][? "sprite"]
			var _pool_i = -1
			for (var _k = 0; _k < ds_list_size(global.player_deck); _k += 2){
				if global.player_deck[| _k] == _cid{ _pool_i = _k div 2; break }
			}
			if _pool_i >= 0 && sprite_exists(_spr){
				array_push(_rm.fly_batch, {
					add: false,   // 飞回卡池
					spr: _spr,
					sx: _rm.x + 805 + (_i - _first) * 86,
					sy: _rm.y + 132,
					tx: (_rm.x + 42 + (_pool_i mod _rm.slot_rows) * 84) + (_rm.x - 25 + 803 - 42),
					ty: (_rm.y + 48 + (_pool_i div _rm.slot_rows) * 96 - _rm.y_offset) + (_rm.y + 375 - 48),
					t: -_n * 2,      // 每张错开 2 帧出发；负值表示还在原槽位等着（绘制时按 0 处理）
					dur: 18,
					pool_i: _pool_i
				})
				_n++
			}
		}
	}
	clear_deck()
	obj_readyroom_manager.deck_first_slot_index = 0   // 清空后回到第一页
}