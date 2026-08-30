var map_sprite = struct_get(ds_map_find_value(global.maps_map,current_map_id),"map_sprite")
draw_sprite(map_sprite,0,room_width/2,room_height/2)

if global.map_id == "delicious_island"{
	if global.save_data.player.level == 6 && global.save_data.unlocked_items.elite_unlocked{
		draw_set_alpha(0.5)
		draw_set_colour(c_black)
		draw_set_valign(fa_top)
		draw_set_halign(fa_left)
		draw_set_font(font_yuan)
		var tooptip_x = 520
		var tooptip_y = 560
		var text = "神殿解锁条件\n在曲奇岛、色拉岛陆或色拉岛水中任选一关通关（"+string(global.save_data.unlocked_items.mario_mouse_killed)+"/1）\n在慕斯岛、香槟岛陆或香槟岛水中任选一关通关（"+string(global.save_data.unlocked_items.arno_killed)+"/1）"
		var tooptip_width = string_width(text)+10
		var tooptip_height = string_height(text)+10
		draw_rectangle(tooptip_x,tooptip_y,tooptip_x+tooptip_width,tooptip_y+tooptip_height,0)
		draw_set_colour(c_white)
		draw_set_alpha(1)
		draw_text(tooptip_x+5,tooptip_y+5,text)
	}
}

if global.map_id == "undersea_vortex"{
	if !is_level_completed("arctic_bay_turbulence_warrior") && global.save_data.player.level >= 50 && is_level_completed("coral_current_night"){
		draw_set_alpha(0.5)
		draw_set_colour(c_black)
		draw_set_valign(fa_top)
		draw_set_halign(fa_left)
		draw_set_font(font_yuan)
		var tooptip_x = 740
		var tooptip_y = 920
		var text = "建议魔塔层数：30-1"
		var tooptip_width = string_width(text)+10
		var tooptip_height = string_height(text)+10
		draw_rectangle(tooptip_x-tooptip_width/2,tooptip_y,tooptip_x+tooptip_width/2,tooptip_y+tooptip_height,0)
		draw_set_colour(c_white)
		draw_set_alpha(1)
		draw_text(tooptip_x+5-tooptip_width/2,tooptip_y+5,text)
	}
}

if global.map_id == "undersea_vortex"{
	if !is_level_completed("tempura_vortex_warrior") && global.save_data.player.level >= 60 && is_level_completed("sea_anemone_current_night"){
		draw_set_alpha(0.5)
		draw_set_colour(c_black)
		draw_set_valign(fa_top)
		draw_set_halign(fa_left)
		draw_set_font(font_yuan)
		var tooptip_x = 1420
		var tooptip_y = 710
		var text = "建议魔塔层数：35-1"
		var tooptip_width = string_width(text)+10
		var tooptip_height = string_height(text)+10
		draw_rectangle(tooptip_x-tooptip_width/2,tooptip_y,tooptip_x+tooptip_width/2,tooptip_y+tooptip_height,0)
		draw_set_colour(c_white)
		draw_set_alpha(1)
		draw_text(tooptip_x+5-tooptip_width/2,tooptip_y+5,text)
	}
}