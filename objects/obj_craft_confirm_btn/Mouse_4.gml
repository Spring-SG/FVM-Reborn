audio_play_sound(snd_button,0,0)

var target_id = obj_craft_bg.current_uprade_target_id
if target_id != ""{
	if obj_craft_bg.button_select == 0{
		var spices_list = [0,0,0]
		var clover_list = [0,0,0]
		var card_data = get_card_info_simple(target_id)
		var current_level = card_data.max_level
		if current_level <= 15{
			var craft_rule_info = get_card_craft_rule(string(current_level+1))
			var display_spices_amount = 0
			var display_clover_amount = 0
			var use_enhanced_spices = false
			var use_enhanced_clover = false
			if get_material_amount(craft_rule_info.spices_require) < craft_rule_info.spices_amount{
				for(var i = array_get_index(spices_use_order,craft_rule_info.spices_require);i < array_length(spices_use_order);i++){
					display_spices_amount += get_material_amount(spices_use_order[i])
					spices_list[i] = get_material_amount(spices_use_order[i])
					if display_spices_amount>= craft_rule_info.spices_amount{
						spices_list[i] -= (display_spices_amount - craft_rule_info.spices_amount)
						use_enhanced_spices = true
						break
					}
				}
			}
			else{
				display_spices_amount = get_material_amount(craft_rule_info.spices_require)
				var sp_index = array_get_index(spices_use_order,craft_rule_info.spices_require)
				spices_list[sp_index] =  craft_rule_info.spices_amount
			}
			if craft_rule_info.clover_require != "none"{
				
				
				if get_material_amount(craft_rule_info.clover_require) < craft_rule_info.clover_amount{
					for(var i = array_get_index(clover_use_order,craft_rule_info.clover_require);i < array_length(clover_use_order);i++){
						display_clover_amount += get_material_amount(clover_use_order[i])
						clover_list[i] = get_material_amount(clover_use_order[i])
						if display_clover_amount>= craft_rule_info.clover_amount{
							clover_list[i] -= (display_clover_amount - craft_rule_info.clover_amount)
							use_enhanced_clover = true
							break
						}
					}
				}
				else{
					display_clover_amount = get_material_amount(craft_rule_info.clover_require)
					var cl_index = array_get_index(clover_use_order,craft_rule_info.clover_require)
					clover_list[cl_index] =  craft_rule_info.clover_amount
				}
			}
			if display_spices_amount >= craft_rule_info.spices_amount &&
				(craft_rule_info.clover_require == "none" || display_clover_amount >= craft_rule_info.clover_amount) &&
				global.save_data.player.gold >= craft_rule_info.gold_amount
			{
				for(var i = 0 ; i < array_length(spices_use_order) ; i++){
					add_material_amount(spices_use_order[i],-spices_list[i])
				}
				if craft_rule_info.clover_require != "none"{
					for(var i = 0 ; i < array_length(clover_use_order) ; i++){
						add_material_amount(clover_use_order[i],-clover_list[i])
					}
				}
				upgrade_card(target_id,current_level+1)
				global.save_data.player.gold -= craft_rule_info.gold_amount
				show_notice("卡片已强化",60)
			}
			else{
				show_notice("金币或强化材料不足，升级失败！",60)
			}
		}
	
	}
	else if obj_craft_bg.button_select == 1{
		var crystal_list = [0,0,0]
		var gem_data = get_gem_info(target_id)
		var current_level = get_gem_max_level(target_id)
		if array_get_index(level_10_gems,target_id) != -1 && current_level >= 10{
			show_notice("该宝石强化上限为10星",60)
		}
		else if current_level <= 14{
			var craft_rule_info = get_gem_craft_rule(string(current_level+1))
			var display_crystal_amount = 0
			var use_enhanced_crystal = false
			if get_material_amount(craft_rule_info.crystal_require) < craft_rule_info.crystal_amount{
				for(var i = array_get_index(crystal_use_order,craft_rule_info.crystal_require);i < array_length(crystal_use_order);i++){
					display_crystal_amount += get_material_amount(crystal_use_order[i])
					crystal_list[i] = get_material_amount(crystal_use_order[i])
					if display_crystal_amount>= craft_rule_info.crystal_amount{
						crystal_list[i] -= (display_crystal_amount - craft_rule_info.crystal_amount)
						use_enhanced_crystal = true
						break
					}
				}
			}
			else{
				display_crystal_amount = get_material_amount(craft_rule_info.crystal_require)
				var cr_index = array_get_index(crystal_use_order,craft_rule_info.crystal_require)
				crystal_list[cr_index] =  craft_rule_info.crystal_amount
			}
			if display_crystal_amount >= craft_rule_info.crystal_amount &&
			global.save_data.player.gold >= craft_rule_info.gold_amount
			{
				for(var i = 0 ; i < array_length(crystal_use_order) ; i++){
					add_material_amount(crystal_use_order[i],-crystal_list[i])
				}
				edit_gem_max_level(target_id,current_level+1)
				edit_gem_level(target_id,get_gem_max_level(target_id))
				global.save_data.player.gold -= craft_rule_info.gold_amount
				show_notice("宝石已强化",60)
			}
			else{
				show_notice("金币或强化水晶不足，升级失败！",60)
			}
		}
	
	}
}
//show_notice("不够好运，升级失败！",60)