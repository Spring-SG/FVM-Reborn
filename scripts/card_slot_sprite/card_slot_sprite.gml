/// @function card_slot_sprite(_card_id)
/// @desc 返回战斗卡槽应使用的背景精灵：
///       幻幻鸡 -> spr_slot_black；商店出售的卡片（营地类型除外）-> spr_slot_purple；其余常规卡片 -> spr_slot_blue
function card_slot_sprite(_card_id) {
	// 商店出售的卡片集合只构建一次（商品表在游戏初始化时注册完毕后就不再变化）
	static _shop_card_set = undefined;
	if (is_undefined(_shop_card_set) && variable_global_exists("goods_map")) {
		_shop_card_set = {};
		var _goods_ids = ds_map_keys_to_array(global.goods_map);
		for (var i = 0; i < array_length(_goods_ids); i++) {
			var _goods = global.goods_map[? _goods_ids[i]];
			if (!is_struct(_goods)) continue;
			// 只统计普通商店里出售的卡片（type == "card"）；
			// 营地（type == "camp"）卖的是形态解锁，不算"商店出售的卡片"
			if (!variable_struct_exists(_goods, "type") || _goods[$ "type"] != "card") continue;
			if (!variable_struct_exists(_goods, "unlock_item_id")) continue;
			var _unlock_id = _goods[$ "unlock_item_id"];
			if (!is_string(_unlock_id) || _unlock_id == "") continue;
			_shop_card_set[$ _unlock_id] = true;
		}
	}

	if (!is_string(_card_id)) return spr_slot_blue;
	if (_card_id == "magic_chicken") return spr_slot_black;
	if (_card_id != "" && !is_undefined(_shop_card_set) && variable_struct_exists(_shop_card_set, _card_id)) {
		return spr_slot_purple;
	}
	return spr_slot_blue;
}