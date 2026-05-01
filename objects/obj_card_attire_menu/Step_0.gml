if !info_got{
	card_attire_id_list = get_card_attire_list(target_card_id)//获取卡片时装列表
	selected_attire_id = card_equipped_attire_id(target_card_id)//获取卡片当前装备时装
	if selected_attire_id != -1{
		selected_attire_index = array_get_index(card_attire_id_list,selected_attire_id)
	}
	var btn4 = instance_create_depth(x-80,y-5,depth-1,obj_card_attire_select_btn)
	btn4.type = "prev"

	var btn5 = instance_create_depth(x+80,y-5,depth-1,obj_card_attire_select_btn)
	btn5.type = "next"
	info_got = true
}