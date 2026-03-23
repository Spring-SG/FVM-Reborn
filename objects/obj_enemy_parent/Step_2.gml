damage_amount = 0
damage_type = ""

if not hp_modified{
	if global.difficulty == 0{
		maxhp *= 0.8
		hp *= 0.8
		helmet_hp *= 0.8
		helmet_max_hp *= 0.8
		shield_hp *= 0.8
		shield_max_hp *= 0.8
	}
	if global.difficulty >= 3{
		if global.map_id != "tower_cake"{
			maxhp *= 1.2
			hp *= 1.2
			helmet_hp *= 1.2
			helmet_max_hp *= 1.2
			shield_hp *= 1.2
			shield_max_hp *= 1.2
		}
		else{
			maxhp *= 1.2
			hp *= 1.2
			helmet_hp *= 1.2
			helmet_max_hp *= 1.2
			shield_hp *= 1.2
			shield_max_hp *= 1.2
		}
	}
	if is_real(global.level_file.version) && !is_boss{
		maxhp *= global.level_file.hp_modify
		hp *= global.level_file.hp_modify
		helmet_hp *= global.level_file.hp_modify
		helmet_max_hp *= global.level_file.hp_modify
		shield_hp *= global.level_file.hp_modify
		shield_max_hp *= global.level_file.hp_modify
	}
	
	hp_modified = true
}