audio_play_sound(snd_button,0,0)

var target_id = obj_craft_bg.current_uprade_target_id
if target_id != ""{
	if obj_craft_bg.button_select == 0{
		var card_data = get_card_info_simple(target_id)
		var current_level = card_data.max_level
		if current_level <= 15{
			var craft_rule_info = get_card_craft_rule(string(current_level+1))
			if get_material_amount(craft_rule_info.spices_require) >= craft_rule_info.spices_amount &&
				(craft_rule_info.clover_require == "none" || get_material_amount(craft_rule_info.spices_require) >= craft_rule_info.spices_amount) &&
				global.save_data.player.gold >= craft_rule_info.gold_amount
			{
				add_material_amount(craft_rule_info.spices_require,-craft_rule_info.spices_amount)
				if craft_rule_info.clover_require != "none"{
					add_material_amount(craft_rule_info.clover_require,-craft_rule_info.clover_amount)
				}
				upgrade_card(target_id,current_level+1)
				global.save_data.player.gold -= craft_rule_info.gold_amount
				show_notice("卡片已强化",60)
			}
			else{
				show_notice("不够好运，升级失败！",60)
			}
		}
	
	}
	else if obj_craft_bg.button_select == 1{
		var gem_data = get_gem_info(target_id)
		var current_level = get_gem_max_level(target_id)
		if array_get_index(level_10_gems,target_id) != -1 && current_level >= 10{
			show_notice("该宝石强化上限为10星",60)
		}
		else if current_level <= 14{
			var craft_rule_info = get_gem_craft_rule(string(current_level+1))
			if get_material_amount(craft_rule_info.crystal_require) >= craft_rule_info.crystal_amount &&
			global.save_data.player.gold >= craft_rule_info.gold_amount
			{
				add_material_amount(craft_rule_info.crystal_require,-craft_rule_info.crystal_amount)
				edit_gem_max_level(target_id,current_level+1)
				edit_gem_level(target_id,get_gem_max_level(target_id))
				global.save_data.player.gold -= craft_rule_info.gold_amount
				show_notice("宝石已强化",60)
			}
			else{
				show_notice("不够好运，升级失败！",60)
			}
		}
	
	}
}
//show_notice("不够好运，升级失败！",60)