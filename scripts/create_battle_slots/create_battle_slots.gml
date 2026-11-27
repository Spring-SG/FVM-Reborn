/// @function create_battle_slots()
/// @desc 根据当前卡组创建战斗卡槽（空槽跳过，非空卡按顺序排布）
function create_battle_slots() {
    var start_x = 535;
    var y_pos = 90;
    var x_spacing = 90;
	var y_spacing = 118;
    
    var n = 0;
    var max_slot = deck_slot_max();
    for(var i = 0; i < max_slot; i++) {
        if (deck_slot_is_empty(i)) continue; // 跳过空槽
        var deck_entry = global.selected_deck[| i];
        var card_data = deck_entry[? "data"];
        var inst = noone
		if n <= 14{
			inst = instance_create_depth(
            start_x + n * x_spacing, 
            y_pos, 
            -5, 
            obj_card_slot
        );
		}
		else{
			inst = instance_create_depth(
            start_x + 14 * x_spacing, 
            y_pos+(n-14)*y_spacing, 
            -5, 
            obj_card_slot
        )
		}
        
        inst.cost = card_data[? "cost"];
        inst.cooldown = card_data[? "cooldown"];
        inst.card_obj = card_data[? "obj"]; 
        inst.card_spr = card_data[? "sprite"];
		inst.place_preview = card_data[? "place_preview"]
        inst.description = card_data[? "description"];
        inst.slot_index = n + 1;
		inst.card_id = deck_entry[? "card_id"];
		// 卡槽背景：幻幻鸡=黑色，商店出售的卡片=紫色，其余常规卡片=蓝色
		inst.sprite_index = card_slot_sprite(inst.card_id);
        inst.shape = deck_entry[? "shape"]; // 存储形态信息
		inst.depth = -2000
		//show_debug_message("植物卡槽已生成，id：" + inst.card_id)
        n++
    }
}