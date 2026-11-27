if on_click and !obj_readyroom_manager.is_submenu_open{
	if deck_slot_count() > 0{
		// 沙漠关卡引导：
		//   芦荟沙丘（夜）→ 防风草沙拉（抵御龙卷风）
		//   沙棘绿洲      → 换气扇（吹散沙尘暴）
		// 开战后一律弹提示；只有「没带这张卡」时才多一道确认窗，由玩家决定要不要继续
		// global.level_id 不带难度后缀，普通/困难都会命中
		var _guide_msg = "";
		var _guide_tip = "";
		if global.level_id == "aloe_dune_night"{
			_guide_tip = "使用防风草沙拉抵御龙卷风"
			if (!deck_has_card("parsnip_salad")){
				_guide_msg = "你没有携带防风草沙拉，\n确定要继续吗？"
			}
		}
		else if global.level_id == "hippophae_oasis"{
			_guide_tip = "使用换气扇吹散沙尘暴"
			if (!deck_has_card("ventilation_fan")){
				_guide_msg = "你没有携带换气扇，\n确定要继续吗？"
			}
		}

		// 提示文本先记到全局：进战后由 obj_battle 的 Create 取走并 show_notice
		// 带没带卡都要写；其他关卡写空串，顺便清掉上一次的残留
		global.level_guide_tip = _guide_tip

		if (_guide_msg != ""){
			if (!instance_exists(obj_level_guide_confirm)){
				var _confirm = instance_create_depth(room_width / 2, room_height / 2, -100, obj_level_guide_confirm)
				_confirm.message = _guide_msg
			}
		}
		else{
			// 带了卡 / 不是这两关：直接开战
			button_pushed = true
			global.audio.play(snd_button,0,0)
		}
	}
	else{
		show_notice("至少需要选择一张防御卡",60)
	}
}
