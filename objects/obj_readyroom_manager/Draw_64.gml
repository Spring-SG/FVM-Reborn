//绘制悬停提示
	if (hover_slot_index != -1 && !is_submenu_open && !deck_slot_is_empty(hover_slot_index) && !instance_exists(obj_package_bg)) {
		var card_data = global.selected_deck[| hover_slot_index][? "data"]
		tooltip_set(mouse_x - 15, mouse_y - 25, card_data[? "description"], -1, 0.7, 1);
		}

// 提示框：推进尺寸/消失动画并绘制（每帧一次）
tooltip_draw(1);