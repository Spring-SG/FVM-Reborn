function battle_event_registry_init(){
	global.battle_event_pool = ds_map_create()
}

function register_battle_event(battle_event_id,battle_event_data){
	ds_map_add(global.battle_event_pool,battle_event_id,battle_event_data)
}

function get_battle_event_data(battle_event_id){
	return ds_map_find_value(global.battle_event_pool,battle_event_id)
}

function battle_event_init(){
	battle_event_registry_init()
	register_battle_event("bat_mouse_spawn",
		{
			"name":"生成蝙蝠鼠",
			"desc":"在地图随机位置，每隔一段时间生成蝙蝠鼠。",
			"params":[
				{
					"param_name":"interval",
					"desc":"生成间隔",
					"type":"real"
				},
				{
					"param_name":"mouse_amount",
					"desc":"生成数量",
					"type":"real"
				}
			]
		}
	)
}