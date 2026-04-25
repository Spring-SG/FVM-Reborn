// obj_battle_pause_manager - Draw Event
if (global.is_paused)
{
    // 1. 绘制半透明遮罩
    
    
    // 2. 根据状态显示不同内容
    if (global.show_menu)
    {
        // 绘制菜单 (示例：居中菜单框)
        var menu_x = room_width / 2;
        var menu_y = room_height / 2;
        
        // 菜单背景
        //draw_set_color(c_white);
        //draw_rectangle(menu_x - 100, menu_y - 100, menu_x + 100, menu_y + 100, false);
        
        // 菜单选项 (示例)
		//draw_set_color(c_black);
        //draw_set_halign(fa_center);
        //draw_text(menu_x, menu_y - 30, "继续游戏");
        //draw_text(menu_x, menu_y + 10, "退出关卡");
        // 这里可以添加菜单交互逻辑
    }
    else
    {
		draw_set_alpha(0.5);
		draw_rectangle_color(0, 0, room_width, room_height, c_black, c_black, c_black, c_black, false);
		draw_set_alpha(1);
        // 只显示"暂停中"文字
		draw_set_font(font_yuan)
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
		draw_set_color(c_white)
		if obj_battle.battle_time == 1{
			draw_sprite_ext(spr_place_player_tip,0,room_width / 2, room_height / 2,1.8,1.8,0,c_white,1)
		}
		else if not global.game_over{
			draw_text(room_width / 2, room_height / 2, "暂停中");
		}
		else{
			if !settlement{
				draw_text(room_width / 2, room_height / 2 + 150, "按空格键继续……");
			}
			else{
				draw_text(room_width / 2, room_height / 2 + 450, "按空格键继续……");
				//绘制结算界面
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				draw_text(630,225, "通关统计");
				var minute = floor(obj_battle.battle_time/3600)
				var second = obj_battle.battle_time/60 - minute * 60
				draw_text(630,260, "通关时间："+string(minute)+":"+string(second));
				draw_text(630,285,"卡片损失："+string(obj_task_manager.card_loss))
				draw_text(630,310,"猫损失："+string(obj_task_manager.cat_loss))
				if global.level_file.version != "1.0.0" && !global.laboretory_room{
					if first_complete{
						var item_string = ""
						var item_list = global.level_file.rewards[1].items
						for(var i = 0 ; i < array_length(item_list) ; i++){
							var item_id = item_list[i].id
							var item_data = get_material_info(item_id)
							item_string += (item_data.name + "（"+string(item_list[i].amount)+"） ")
						}
						//draw_text(100,900,item_string)
						//draw_text(100,940,"等级："+string(global.level_file.rewards[1].player_level)+"级")
						var card_string = ""
						var card_unlock_id_list = global.level_file.rewards[1].card_unlock
						for(var i = 0 ; i < array_length(card_unlock_id_list) ; i++){
							var card_id = card_unlock_id_list[i]
							var card_data = get_plant_shape_data(card_id,0)
							card_string += (card_data[? "name"] + " ")
						}
						//draw_text(100,980,"卡片解锁："+card_string)
						var weapon_string = ""
						var weapon_unlock_id_list = global.level_file.rewards[1].weapon_unlock
						for(var i = 0 ; i < array_length(weapon_unlock_id_list) ; i++){
							var weapon_id = weapon_unlock_id_list[i]
							var weapon_data = get_weapon_info(weapon_id)
							weapon_string += (weapon_data.name + " ")
						}
						//draw_text(100,1020,"武器解锁："+weapon_string)
						var gem_string = ""
						var gem_unlock_id_list = global.level_file.rewards[1].gem_unlock
						for(var i = 0 ; i < array_length(gem_unlock_id_list) ; i++){
							var gem_id = gem_unlock_id_list[i]
							var gem_data = get_gem_info(gem_id)
							gem_string += (gem_data.name + " ")
						}
						//draw_text(100,1060,"宝石解锁："+gem_string)
						draw_text(1200,225, "关卡奖励");
						draw_text(1200,260,"金币（"+string(global.level_file.rewards[1].gold)+"）")
						draw_text(1200,285,"技能："+string(global.level_file.rewards[1].skill_level)+"级")
						draw_text(1200,310,item_string)
						draw_text(1200,335,"等级："+string(global.level_file.rewards[1].player_level)+"级")
						draw_text(1200,360,"卡片解锁："+card_string)
						draw_text(1200,385,"武器解锁："+weapon_string)
						draw_text(1200,410,"宝石解锁："+gem_string)
						if global.level_data.id == "champagne_island_water"{
							draw_set_colour(c_yellow)
							draw_text(1200,435,"你已解锁精英段，击败洞君和阿诺各一次以解锁神殿")
						}
						if global.level_data.id == "abyss"{
							draw_set_colour(c_yellow)
							draw_text(1200,435,"你的铲子已升级为铜铲")
						}
						if global.level_data.id == "macchiato_port"{
							draw_set_colour(c_yellow)
							draw_text(1200,435,"你的铲子已升级为银铲")
						}
						if global.level_data.id == "snowcap_volcano"{
							draw_set_colour(c_yellow)
							draw_text(1200,435,"你的铲子已升级为金铲")
						}
						
					}
					else{
						draw_text(1200,225, "关卡奖励");
						var item_string = ""
						var item_list = global.level_file.rewards[0].items
						for(var i = 0 ; i < array_length(item_list) ; i++){
							var item_id = item_list[i].id
							var item_data = get_material_info(item_id)
							item_string += (item_data.name + "（"+string(item_list[i].amount)+"） ")
						}
						draw_text(1200,260,"金币（"+string(global.level_file.rewards[0].gold)+"）")
						draw_text(1200,285,item_string)
					}
				}
			}
			if obj_game_over.sprite_index == spr_lose{
				draw_text(room_width / 2, room_height / 2 + 175, "按R重新开始")
			}
		}
    }
}