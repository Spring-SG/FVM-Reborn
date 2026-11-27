// 菜单页面开着时不分页（面板盖在上面看不见，但翻页会改到底下卡槽的状态）
if obj_readyroom_manager.is_submenu_open exit

// 卡槽分页：每页 11 格，第一页 = 下标 0~10，第二页 = 下标 10~20
// 注意：下标 10（第 11 个槽）两页都显示 —— 它是第一页的最后一格、也是第二页的第一格，故意重叠
if type == "prev"{
	if obj_readyroom_manager.deck_first_slot_index >= 10{
		obj_readyroom_manager.deck_first_slot_index -= 10
	}
	else{
		obj_readyroom_manager.deck_first_slot_index = 10
	}
}
else{
	if obj_readyroom_manager.deck_first_slot_index < 10{
		obj_readyroom_manager.deck_first_slot_index += 10
	}
	else{
		obj_readyroom_manager.deck_first_slot_index = 0
	}
}
global.audio.play(snd_button,0,0)