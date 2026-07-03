/// @function get_card_info(card_id)
/// @desc 根据卡片ID获取卡片信息，如果未解锁则返回false
/// @param {string} card_id 卡片ID
/// @return {struct|bool} 卡片信息结构体或false（未解锁）
function get_card_info(card_id) {

    // 检查卡片是否已解锁
    for (var i = 0; i < array_length(global.save_data.unlocked_cards); i++) {
        if (global.save_data.unlocked_cards[i].id == card_id) {
            // 卡片已解锁，返回详细信息
            var card_info1 = {
                unlocked: true,
                id: global.save_data.unlocked_cards[i].id,
                level: global.save_data.unlocked_cards[i].level,
                shape: global.save_data.unlocked_cards[i].shape,
				skill: global.save_data.unlocked_cards[i].skill,
				max_shape: global.save_data.unlocked_cards[i].max_shape,
				max_level: global.save_data.unlocked_cards[i].max_level,
            };
            
            // 尝试获取卡片的完整数据（从注册的卡牌数据中）
            var card_data = deck_get_card_data(card_id,0);
            if (card_data != noone) {
                card_info1.obj = card_data[? CARD_DATA.obj];
                card_info1.spr = card_data[? CARD_DATA.spr];
                card_info1.cost = card_data[? CARD_DATA.cost];
                card_info1.cooldown = card_data[? CARD_DATA.cooldown];
                card_info1.description = card_data[? CARD_DATA.description];
            }
            
            return card_info1;
        }
    }
    
    // 卡片未解锁
	if (global.network.mode=="server"&&card_id!=""){
        var card_info1 = {
            unlocked: true,
            id: card_id,
            level: 0,
            shape: 0,
			skill: 0,
			max_shape:3,
			max_level: 13,
        };
            
        // 尝试获取卡片的完整数据（从注册的卡牌数据中）
        var card_data = deck_get_card_data(card_id,0);
        if (card_data != noone) {
            card_info1.obj = card_data[? CARD_DATA.obj];
            card_info1.spr = card_data[? CARD_DATA.spr];
            card_info1.cost = card_data[? CARD_DATA.cost];
            card_info1.cooldown = card_data[? CARD_DATA.cooldown];
            card_info1.description = card_data[? CARD_DATA.description];
        }
         return card_info1;
	}
    return false;
}

/// @function get_card_info_simple(card_id)
/// @desc 简化版本，只返回解锁状态和基本属性，不包含卡牌数据
/// @param {string} card_id 卡片ID
/// @return {struct|bool} 卡片基本信息结构体或false（未解锁）
function get_card_info_simple(card_id) {
    // 检查卡片是否已解锁
    for (var i = 0; i < array_length(global.save_data.unlocked_cards); i++) {
        if (global.save_data.unlocked_cards[i].id == card_id) {
            // 卡片已解锁，返回基本信息
            return {
                unlocked: true,
                id: global.save_data.unlocked_cards[i].id,
                level: global.save_data.unlocked_cards[i].level,
                shape: global.save_data.unlocked_cards[i].shape,
				skill: global.save_data.unlocked_cards[i].skill,
				max_shape: global.save_data.unlocked_cards[i].max_shape,
				max_level: global.save_data.unlocked_cards[i].max_level,
            };
        }
    }    
    // 卡片未解锁
		
	if(global.network.mode=="server" &&card_id!=""){
        return {
            unlocked: true,
            id: card_id,
            level: 0,
            shape: 0,
			skill: 0,
			max_shape: 3,
			max_level: 13,
        };
	}
    return false;
}