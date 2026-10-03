if obj_readyroom_manager.selected_custom_deck != deck_index && !obj_readyroom_manager.is_submenu_open{
	obj_readyroom_manager.selected_custom_deck = deck_index
	global.audio.play(snd_button,0,0)
	load_custom_deck(deck_index-1)
	// 点卡组后：卡池里对应的卡按槽位顺序逐张飞进卡槽（与「清空」飞回去同一套，只是方向相反）
	var _rm = obj_readyroom_manager
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
					add: true,   // 飞入卡槽（卡池 → 卡槽）
					slot: _i,    // 这一条属于哪个槽位：飞行期间该槽位不画静态卡
					spr: _spr,
					sx: (_rm.x + 42 + (_pool_i mod _rm.slot_rows) * 84) + (_rm.x - 25 + 803 - 42),
					sy: (_rm.y + 48 + (_pool_i div _rm.slot_rows) * 96 - _rm.y_offset) + (_rm.y + 375 - 48),
					tx: _rm.x + 805 + (_i - _first) * 86,
					ty: _rm.y + 132,
					t: -_n * 2,   // 按槽位顺序每张错开 2 帧起飞
					dur: 18,
					pool_i: _pool_i
				})
				_n++
			}
		}
	}
}