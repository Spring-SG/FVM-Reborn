if hover_card_index != -1 && !is_submenu_open{
	var _slot = deck_slot_first_empty()
	if _slot != -1{
		global.audio.play(snd_button,0,0)
		var card_id = global.player_deck[| hover_card_index*2];
		if add_to_deck(card_id,get_card_info_simple(card_id).shape){
			// 第一页填满第 11 槽（下标 10）不翻页；再放一张、它落到下标 11 时才翻到第二页（先翻再算终点）
			if deck_first_slot_index == 0 && _slot >= 11{
				deck_first_slot_index = 10
			}
			// 飞入卡槽：起点 = 绘制时记下的悬停卡片屏幕位置；终点槽位公式与 Draw_0 的槽位循环一致
			var _vis = _slot - deck_first_slot_index
			if _vis >= 0 && _vis < 11{
				fly_add = true
				fly_spr = hover_card_spr
				fly_sx = hover_card_x
				fly_sy = hover_card_y
				fly_tx = x + 805 + _vis * 86
				fly_ty = y + 132
				fly_slot = _slot
				fly_dur = 18          // 固定 18 帧（60fps ≈ 0.3s）；曲线在 Draw_76 里（非线性缓出）
				fly_t = 0
				fly_active = true
			}
		}
	}
}
if hover_slot_index != -1 && !is_submenu_open{
	if !deck_slot_is_empty(hover_slot_index){
		global.audio.play(snd_button,0,0)
		// 移除前先记下起点位置与精灵（移除后槽位数据就没了）
		var _src_x = x + 805 + (hover_slot_index - deck_first_slot_index) * 86
		var _src_y = y + 132
		var _entry = global.selected_deck[| hover_slot_index]
		var _card_id = _entry[? "card_id"]
		var _spr = _entry[? "data"][? "sprite"]
		remove_from_deck(hover_slot_index)
		// 第二页：只有下标 11~20 全空（第 11 槽是两页共享的，不算第二页独占内容）才翻回第一页
		if deck_first_slot_index >= 10{
			var _rest_empty = true
			for (var _i = 11; _i < deck_slot_max(); _i++){
				if !deck_slot_is_empty(_i){ _rest_empty = false; break }
			}
			if _rest_empty deck_first_slot_index = 0
		}
		// 飞回卡池：终点 = 这张卡在网格里的格子（网格画在 surface 上，要加 Draw_0:120 的贴图偏移）
		var _pool_i = -1
		for (var _k = 0; _k < ds_list_size(global.player_deck); _k += 2){
			if global.player_deck[| _k] == _card_id{ _pool_i = _k div 2; break }
		}
		if _pool_i >= 0 && sprite_exists(_spr){
			fly_add = false
			fly_spr = _spr
			fly_sx = _src_x
			fly_sy = _src_y
			fly_tx = (x + 42 + (_pool_i mod slot_rows) * 84) + (x - 25 + 803 - 42)
			fly_ty = (y + 48 + (_pool_i div slot_rows) * 96 - y_offset) + (y + 375 - 48)
			fly_slot = -1
			fly_pool_i = _pool_i   // 落地前这张卡在卡池里继续按"已选"灰显
			fly_dur = 18
			fly_t = 0
			fly_active = true
		}
	}
}
if(mouse_x > 785 && mouse_x < 1546 && mouse_y > 762 && mouse_y < 980) && !is_submenu_open{
	global.audio.play(snd_button,0,0)
	var inst = instance_create_depth(0,0,-500,obj_level_preview)
	inst.enemy_type_list = enemy_type_list
	inst.boss_type_list = boss_type_list
}
