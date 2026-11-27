/// @function add_to_deck(card_id, shape, slot_index)
/// @desc 添加指定形态的卡牌到当前出战卡组（默认填入最靠前空槽；slot_index>=0 时精确填入该槽）
function add_to_deck(card_id, shape, slot_index = -1) {
    var card_data = deck_get_card_data(card_id, shape);
    if (card_data == noone) return false;

    // 确保卡组槽位已初始化（长度 = max_slot，空槽用 [deck_empty_slot] 占位）
    deck_ensure_size();

    var deck_entry = ds_map_create();
    deck_entry[? "card_id"] = card_id;
    deck_entry[? "shape"] = shape;
    deck_entry[? "data"] = card_data;

    // 槽位选择：精确填入指定槽（读档还原用）或最靠前空槽
    var idx = -1;
    if (slot_index >= 0 && slot_index < ds_list_size(global.selected_deck)) {
        idx = slot_index;
    }
    else {
        idx = deck_slot_first_empty();
    }

    if (idx == -1) { // 卡组已满
        ds_map_destroy(deck_entry);
        return false;
    }

    // 覆盖旧槽位前清理旧数据
    var old = global.selected_deck[| idx];
    if (old != global.deck_empty_slot && ds_exists(old, ds_type_map)) {
        ds_map_destroy(old);
    }
    global.selected_deck[| idx] = deck_entry;
    return true;
}

/// @function deck_slot_max()
/// @desc 出战卡组槽位总数（= 已解锁的 max_slot；无存档兜底 21）
function deck_slot_max() {
    if (variable_global_exists("save_data") && !is_undefined(global.save_data)
        && variable_struct_exists(global.save_data, "unlocked_items")) {
        return global.save_data.unlocked_items.max_slot;
    }
    return 21;
}

/// @function deck_empty_slot_ensure()
/// @desc 确保全局空槽标记 ds_map 存在（幂等；card_id=""）
function deck_empty_slot_ensure() {
    if (!variable_global_exists("deck_empty_slot") || is_undefined(global.deck_empty_slot) || global.deck_empty_slot == -1) {
        global.deck_empty_slot = ds_map_create();
        global.deck_empty_slot[? "card_id"] = "";
        global.deck_empty_slot[? "shape"] = -1;
        global.deck_empty_slot[? "data"] = noone;
    }
    return global.deck_empty_slot;
}

/// @function deck_ensure_size()
/// @desc 把 selected_deck 补齐到 max_slot 长度（不足追加以 [deck_empty_slot] 占位）
function deck_ensure_size() {
    deck_empty_slot_ensure();
    var _max = deck_slot_max();
    while (ds_list_size(global.selected_deck) < _max) {
        ds_list_add(global.selected_deck, global.deck_empty_slot);
    }
}

/// @function deck_slot_is_empty(i)
/// @desc 判断槽位 i 是否为空（越界/标记/undefined/noone/card_id=="" 均判空）
function deck_slot_is_empty(i) {
    if (i < 0 || i >= ds_list_size(global.selected_deck)) return true;
    var e = global.selected_deck[| i];
    if (e == global.deck_empty_slot) return true;
    if (e == undefined || e == noone) return true;
    return (e[? "card_id"] == "");
}

/// @function deck_slot_count()
/// @desc 当前非空卡数量（= 实际出战卡数）
function deck_slot_count() {
    deck_ensure_size();
    var n = 0;
    var _max = ds_list_size(global.selected_deck);
    for (var i = 0; i < _max; i++) {
        if (!deck_slot_is_empty(i)) n++;
    }
    return n;
}

/// @function deck_slot_first_empty()
/// @desc 返回最靠前空槽下标，无空槽返回 -1
function deck_slot_first_empty() {
    deck_ensure_size();
    var _max = ds_list_size(global.selected_deck);
    for (var i = 0; i < _max; i++) {
        if (deck_slot_is_empty(i)) return i;
    }
    return -1;
}

/// @function remove_from_deck(i)
/// @desc 移除指定槽位的卡，槽位保留为空（不补位）
function remove_from_deck(i) {
    deck_ensure_size();
    if (i < 0 || i >= ds_list_size(global.selected_deck)) return;
    if (deck_slot_is_empty(i)) return;
    var old = global.selected_deck[| i];
    if (old != global.deck_empty_slot && ds_exists(old, ds_type_map)) {
        ds_map_destroy(old);
    }
    global.selected_deck[| i] = global.deck_empty_slot;
}

/// @function clear_deck()
/// @desc 清空整个卡组（所有槽位置空，长度保留 max_slot）
function clear_deck() {
    var _max = deck_slot_max();
    ds_list_clear(global.selected_deck);
    deck_empty_slot_ensure();
    for (var i = 0; i < _max; i++) {
        ds_list_add(global.selected_deck, global.deck_empty_slot);
    }
}

/// @function deck_has_card(card_id)
/// @desc 当前出战卡组里是否带了这张卡（任意形态；只看 card_id，不看 shape）
function deck_has_card(card_id) {
    if (card_id == "") return false;
    deck_ensure_size();
    var _max = ds_list_size(global.selected_deck);
    for (var i = 0; i < _max; i++) {
        if (deck_slot_is_empty(i)) continue;
        var e = global.selected_deck[| i];
        if (e[? "card_id"] == card_id) return true;
    }
    return false;
}