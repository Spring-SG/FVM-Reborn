for(var i = 0 ; i < array_length(hp_increase_card_list) ; i ++){
	if hp_increase_card_list[i] != noone && instance_exists(hp_increase_card_list[i]){
		with hp_increase_card_list[i]{
			if hp < max_hp{
				if hp < max_hp - 10{
					hp += 10
				}
				else{
					hp = max_hp
				}
				instance_create_depth(x,y+30,depth-4,obj_card_heal_effect)
			}
		}
	}
}