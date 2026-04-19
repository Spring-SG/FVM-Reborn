function plus_card_init(){
	global.plus_card_map = ds_map_create()
	ds_map_add(global.plus_card_map,"large_fire",[obj_large_fire,2])
	ds_map_add(global.plus_card_map,"rotating_coffee_pot",[obj_rotating_coffee_pot,1])
	ds_map_add(global.plus_card_map,"gatlin_long_bao",[obj_gatlin_long_bao,1])
	ds_map_add(global.plus_card_map,"iron_fishbone",[obj_iron_fishbone,1])
	ds_map_add(global.plus_card_map,"takoyaki",[obj_takoyaki,2])
	ds_map_add(global.plus_card_map,"chocolate_bread",[obj_chocolate_bread,1])
	ds_map_add(global.plus_card_map,"ice_egg_boiler_pult",[obj_ice_egg_boiler_pult,1])
	ds_map_add(global.plus_card_map,"chocolate_cannon",[obj_chocolate_cannon,1])
	ds_map_add(global.plus_card_map,"gatlin_ice_long_bao",[obj_gatlin_ice_long_bao,1])
	ds_map_add(global.plus_card_map,"pineapple_explosive_bread",[obj_pineapple_explosive_bread,1])
}