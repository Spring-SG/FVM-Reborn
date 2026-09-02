if !is_cookbook_equipped(cookbook_id){
	var cookbook_material = ["copper_cookbook_fragment","silver_cookbook_fragment","gold_cookbook_fragment"]
	var max_cookbook_slot = clamp(get_material_amount(cookbook_material[cookbook_rank]),0,2)
	var current_cookbook_amount = array_length(global.save_data.equipped_cookbook[cookbook_rank])
	if current_cookbook_amount < max_cookbook_slot{
		equip_cookbook(cookbook_id)
		audio_play_sound(snd_button,0,0)
		show_notice("食谱已装配",60)
	}
	else{
		show_notice("当前类型的食谱槽位已满",60)
	}
}
else{
	unequip_cookbook(cookbook_id)
	audio_play_sound(snd_button,0,0)
	show_notice("食谱已卸下",60)
}