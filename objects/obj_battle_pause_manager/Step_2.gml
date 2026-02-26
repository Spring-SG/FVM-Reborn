// obj_battle_pause_manager - Step Event
if (keyboard_check_pressed(vk_space)) {	
    //if global.selected_slot == noone {
        if (!global.is_paused) {
            // 空格暂停：只暂停不显示菜单
            global.is_paused = true;
            global.show_menu = false;
        }
        else if (global.is_paused && !global.show_menu) {
            // 取消暂停
			if global.game_over{
				if settlement || obj_game_over.sprite_index == spr_lose || global.level_file.version == "1.0.0"{
					room_goto(room_map)
					global.menu_screen = true
				}
				if global.level_file.version != "1.0.0"{
					if obj_game_over.sprite_index == spr_win && !settlement{
						with obj_task_manager{
							refresh_task_progress()
						}
						if array_get_index(global.save_data.completed_levels,global.level_data.id) == -1{
							complete_level(global.level_data.id)
							first_complete = true
							if array_get_index(slot_unlock_level_id_list,global.level_data.id) != -1{
								if global.save_data.unlocked_items.max_slot < 21{
									global.save_data.unlocked_items.max_slot += 1
									show_notice("你解锁了一个新的卡槽",60)
								}
							}
							if global.level_data.id == "champagne_island_water"{
								global.save_data.unlocked_items.elite_unlocked = true
							}
							if global.level_data.id == "abyss"{
								global.save_data.unlocked_items.shovel = "copper"
							}
							if global.level_file.rewards[1].player_level >= global.save_data.player.level{
								global.save_data.player.level = global.level_file.rewards[1].player_level
							}
							if global.level_file.rewards[1].skill_level >= global.save_data.unlocked_items.max_skill_level{
								global.save_data.unlocked_items.max_skill_level = global.level_file.rewards[1].skill_level
								var length = array_length(global.save_data.unlocked_cards)
								for (var i = 0;i < length;i++){		
									global.save_data.unlocked_cards[i].skill = global.save_data.unlocked_items.max_skill_level
								}
								
							}
							global.save_data.player.gold += global.level_file.rewards[1].gold
							var item_list = global.level_file.rewards[1].items
							for(var i = 0 ; i < array_length(item_list) ; i++){
								var item_id = item_list[i].id
								add_material_amount(item_id,real(item_list[i].amount))
							}
						
							var card_unlock_id_list = global.level_file.rewards[1].card_unlock
							for(var i = 0 ; i < array_length(card_unlock_id_list) ; i++){
								var card_id = card_unlock_id_list[i]
								unlock_card(card_id,0,0,global.save_data.unlocked_items.max_skill_level)
							}
						
							var weapon_unlock_id_list = global.level_file.rewards[1].weapon_unlock
							for(var i = 0 ; i < array_length(weapon_unlock_id_list) ; i++){
								var weapon_id = weapon_unlock_id_list[i]
								unlock_weapon(weapon_id)
							}
						
							var gem_unlock_id_list = global.level_file.rewards[1].gem_unlock
							for(var i = 0 ; i < array_length(gem_unlock_id_list) ; i++){
								var gem_id = gem_unlock_id_list[i]
								unlock_gem(gem_id)
							}
							save_file(global.save_slot)
						}
						else{
							global.save_data.player.gold += global.level_file.rewards[0].gold
							var item_list = global.level_file.rewards[0].items
							for(var i = 0 ; i < array_length(item_list) ; i++){
								var item_id = item_list[i].id
								add_material_amount(item_id,item_list[i].amount)
							}
							save_file(global.save_slot)
						}
						settlement = true
						obj_game_over.image_alpha = 0
					}
				}
				
			}
			if obj_battle.battle_time != 0 && !global.game_over{
				global.is_paused = false;
			}
        }
    //}
}

if (keyboard_check_pressed(vk_escape)) {
    if (!global.is_paused) {
        // ESC暂停：暂停并显示菜单
        global.is_paused = true;
        global.show_menu = true;
        
        // 创建暂停菜单实例
        
        instance_create_depth(room_width / 2, room_height / 2, depth, obj_pause_menu);
    }
    else if (global.is_paused && global.show_menu) {
        // 尝试关闭菜单（菜单自身会处理ESC关闭）
        var menu = instance_find(obj_pause_menu, 0);
        if (menu != noone && !menu.submenu_open) {
            instance_destroy(menu);
            global.is_paused = false;
            global.show_menu = false;
        }
    }
}

if (keyboard_check_pressed(ord("R"))) {
	if global.game_over{
		if obj_game_over.sprite_index == spr_lose{
			room_restart()
		}
	}
}

if obj_battle.battle_time == 1{
	global.is_paused = true;
}