function attire_registry_init(){
	global.attire_pool = ds_map_create()
}

///@function get_attire_info(attire_id)
///@description 获取时装数据
///@param {string}attire_id 时装id
///@return {struct}
function get_attire_info(attire_id){
	return ds_map_find_value(global.attire_pool,attire_id)
}

///@function register_attire(attire_id,attire_data)
///@description 注册时装
///@param {string}attire_id 时装id
///@param {struct}attire_data 时装数据
function register_attire(attire_id,attire_data){
	ds_map_add(global.attire_pool,attire_id,attire_data)
}


function attire_init(){
	attire_registry_init()
	//注册全部卡片时装
	register_attire(
		"ice_egg_pisces",
		{
			"target_card":"ice_egg_boiler_pult",
			"name":"双鱼座精灵",
			"icon":spr_ice_egg_pisces_icon,
			"spr":[spr_ice_egg_pisces,spr_ice_egg_pisces_1,spr_ice_egg_pisces_2],
			"card_slot_icon":[spr_ice_egg_pisces_icon,spr_ice_egg_pisces_icon_1,spr_ice_egg_pisces_icon_2]
		}
	)
	register_attire(
		"water_pipe_libra",
		{
			"target_card":"double_water_pipe",
			"name":"天秤座精灵",
			"icon":spr_water_pipe_libra,
			"spr":[spr_water_pipe_libra,spr_water_pipe_libra_1,spr_water_pipe_libra_2],
			"card_slot_icon":[spr_water_pipe_libra,spr_water_pipe_libra_1,spr_water_pipe_libra_2]
		}
	)
	register_attire(
		"wine_rack_sagittarius",
		{
			"target_card":"triple_wine_rack",
			"name":"射手座精灵",
			"icon":spr_wine_rack_sagittarius_icon,
			"spr":[spr_wine_rack_sagittarius,spr_wine_rack_sagittarius_1,spr_wine_rack_sagittarius_2],
			"card_slot_icon":[spr_wine_rack_sagittarius_icon,spr_wine_rack_sagittarius_icon_1,spr_wine_rack_sagittarius_icon_2]
		}
	)
	register_attire(
		"brazier_taurus",
		{
			"target_card":"brazier",
			"name":"金牛座精灵",
			"icon":spr_brazier_taurus,
			"spr":[spr_brazier_taurus,spr_brazier_taurus_1,spr_brazier_taurus_2],
			"card_slot_icon":[spr_brazier_taurus,spr_brazier_taurus_1,spr_brazier_taurus_2]
		}
	)
	register_attire(
		"large_fire_gemini",
		{
			"target_card":"large_fire",
			"name":"双子座精灵",
			"icon":spr_large_fire_gemini_icon,
			"spr":[spr_large_fire_gemini,spr_large_fire_gemini_1,spr_large_fire_gemini_2],
			"card_slot_icon":[spr_large_fire_gemini_icon,spr_large_fire_gemini_icon_1,spr_large_fire_gemini_icon_2]
		}
	)
	register_attire(
		"takoyaki_cancer",
		{
			"target_card":"takoyaki",
			"name":"巨蟹座精灵",
			"icon":spr_takoyaki_cancer_icon,
			"spr":[spr_takoyaki_cancer,spr_takoyaki_cancer_1,spr_takoyaki_cancer_2],
			"card_slot_icon":[spr_takoyaki_cancer_icon,spr_takoyaki_cancer_icon_1,spr_takoyaki_cancer_icon_2]
		}
	)
	register_attire(
		"gatling_popcorn",
		{
			"target_card":"gatlin_long_bao",
			"name":"玉蜀黍",
			"icon":spr_gatling_popcorn_icon,
			"spr":[spr_gatling_popcorn,spr_gatling_popcorn_1,spr_gatling_popcorn_2],
			"card_slot_icon":[spr_gatling_popcorn_icon,spr_gatling_popcorn_icon_1,spr_gatling_popcorn_icon_2]
		}
	)
	register_attire(
		"rotate_leo",
		{
			"target_card":"rotating_coffee_pot",
			"name":"狮子座精灵",
			"icon":spr_rotate_leo_icon,
			"spr":[spr_rotate_leo,spr_rotate_leo_1,spr_rotate_leo_2],
			"card_slot_icon":[spr_rotate_leo_icon,spr_rotate_leo_icon_1,spr_rotate_leo_icon_2]
		}
	)
	register_attire(
		"melon_virgo",
		{
			"target_card":"melon_shield",
			"name":"处女座精灵",
			"icon":spr_melon_virgo_icon,
			"spr":[spr_melon_virgo_icon,spr_melon_virgo_icon_1,spr_melon_virgo_icon_2],
			"outer_spr":[
				[spr_melon_virgo_outer_1,spr_melon_virgo_outer_1,spr_melon_virgo_outer_1],
				[spr_melon_virgo_1_outer_1,spr_melon_virgo_1_outer_2,spr_melon_virgo_1_outer_3],
				[spr_melon_virgo_2_outer_1,spr_melon_virgo_2_outer_2,spr_melon_virgo_2_outer_3]
			],
			"card_slot_icon":[spr_melon_virgo_icon,spr_melon_virgo_icon_1,spr_melon_virgo_icon_2],
			"inner_spr":[spr_melon_virgo_inner_1,spr_melon_virgo_inner_2,spr_melon_virgo_inner_3]
		}
	)
	
	//注册全部玩家时装
	register_attire(
		"player_attire_1",
		{
			"target_card":"player",
			"name":"雪球兔兔",
			"icon":spr_player_attire_1_icon,
			"spr":spr_player_attire_1,
		}
	)
	register_attire(
		"player_attire_2",
		{
			"target_card":"player",
			"name":"提拉米苏",
			"icon":spr_player_attire_2_icon,
			"spr":spr_player_attire_2,
		}
	)
	register_attire(
		"player_attire_3",
		{
			"target_card":"player",
			"name":"魔影圣衣",
			"icon":spr_player_attire_3_icon,
			"spr":spr_player_attire_3,
		}
	)
	register_attire(
		"player_attire_4",
		{
			"target_card":"player",
			"name":"公会制服",
			"icon":spr_player_attire_4_icon,
			"spr":spr_player_attire_4,
		}
	)
	register_attire(
		"player_attire_5",
		{
			"target_card":"player",
			"name":"龙族传说",
			"icon":spr_player_attire_5_icon,
			"spr":spr_player_attire_5,
		}
	)
	register_attire(
		"player_attire_6",
		{
			"target_card":"player",
			"name":"神奇精灵",
			"icon":spr_player_attire_6_icon,
			"spr":spr_player_attire_6,
		}
	)
}