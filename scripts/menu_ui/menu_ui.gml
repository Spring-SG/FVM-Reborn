/// menu_ui —— 主界面菜单（菜单栏 7 个按钮 + 6 个全屏页面）的状态读写
///
/// 菜单房 / 地图房把状态记在 obj_player_info_ui.menu_type 与 obj_world_map_button.world_map 上
/// （0 = 正常，3 = 世界地图开着，4 = 有页面或二级菜单占着）。
/// 备战房间（room_ready）里这两个实例都不存在，但菜单栏（obj_player_menu_bg）照样会出现，
/// 所以任何「读 / 写这两项状态」的代码都必须走本脚本的函数 ——
/// 直接写 obj_player_info_ui.xxx 在没有该实例的房间会抛 instance does not exist 直接崩。
///
/// 页面 = 背包 obj_package_bg / 情报岛 obj_info_island_bg / 商城 obj_shop_bg /
///        任务 obj_task_bg / 合成屋 obj_craft_bg / 食神谱 obj_cookbook_bg

/// @description 当前开着的菜单页面（对象索引）；没开返回 noone
function menu_ui_open_page(){
	var _pages = [obj_package_bg, obj_info_island_bg, obj_shop_bg, obj_task_bg, obj_craft_bg, obj_cookbook_bg]
	for (var i = 0; i < array_length(_pages); i++){
		if (instance_exists(_pages[i])) return _pages[i]
	}
	return noone
}

/// @description 是否有菜单页面开着
function menu_ui_page_exists(){
	return menu_ui_open_page() != noone
}

/// @description 菜单栏按钮此刻是否该忽略点击：有页面 / 确认框 / 关卡预览占着，或 menu_type 非 0。
///              取代原来 obj_player_menu_btn 里裸写的 obj_player_info_ui.menu_type == 0
function menu_ui_busy(){
	if (instance_exists(obj_player_info_ui) && obj_player_info_ui.menu_type != 0){
		return true
	}
	if (menu_ui_page_exists()) return true
	// 备战房间点「退出」只弹确认框（没有 menu_type 帮忙挡住菜单栏），这里补上
	if (instance_exists(obj_quit_confirm)) return true
	// 备战房间的关卡引导确认窗同理
	if (instance_exists(obj_level_guide_confirm)) return true
	if (instance_exists(obj_level_preview)) return true
	return false
}

/// @description 写 menu_type；没有 obj_player_info_ui 的房间（备战房间）就当无事发生
function menu_ui_set_type(_v){
	if (instance_exists(obj_player_info_ui)){
		obj_player_info_ui.menu_type = _v
	}
}

/// @description 写 obj_world_map_button.world_map；没有该实例就当无事发生
function menu_ui_set_world_map(_v){
	if (instance_exists(obj_world_map_button)){
		obj_world_map_button.world_map = _v
	}
}

/// @description 页面销毁时统一复位（替代原来 Destroy 里直写两个对象的那两行）
function menu_ui_reset(){
	menu_ui_set_type(0)
	menu_ui_set_world_map(0)
}

/// @description 关掉当前开着的菜单页面（已经在关就当作已处理）。返回是否有页面被关
function menu_ui_close_page(){
	var _page = menu_ui_open_page()
	if (_page == noone) return false
	var _closing = false
	with (_page){
		_closing = variable_instance_exists(id, "pnl_closing") && pnl_closing
	}
	if (!_closing) panel_anim_close(_page)
	return true
}