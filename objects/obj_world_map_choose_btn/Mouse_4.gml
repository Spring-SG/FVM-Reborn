if unlocked{
	global.audio.play(snd_button,0,0)
	obj_world_map_button.world_map = 0
	panel_anim_close(obj_world_map_menu)   // 选完地图反向滑出，播完销毁
	if map_id == "undersea_vortex"{
		texture_prefetch("pack_undersea_vortex")
	}
	if map_id != "tower_cake"{
		// 未注册的 id（默认 delicious_town 等）不要带进全局
		var _known = ds_map_exists(global.maps_map, map_id)
		if room != room_target{
			// 要换房：现在就把地图改掉，新房间的 Create 会读它
			if _known && global.map_id != map_id{
				global.map_name = map_name
				global.map_id = map_id
			}
			global.gui_stack.to(room_target)
		}
		else if _known && global.map_id != map_id{
			// 同一个房间里换地图（美味岛 → 火山岛 / 浮空岛…）：也淡出淡入，全黑那一刻才换
			room_transition_in_place(map_switch_apply, { id: map_id, name: map_name })
		}
	}
	else{
		global.gui_stack.to(room_tower_cake)
	}
}
else{
	if level_require > 80{
		show_notice("暂未开放，敬请期待！",60)
	}
	else{
		show_notice("达到"+string(level_require)+"级以解锁此地图",60)
	}
}