Enum_Init()
deck_init()
slots_init()
skill_registry_init();
skill_init()
weapon_registry_init()
gem_registry_init()
weapons_init()
info_island_register_init()
info_island_init()
goods_registry_init()
shop_init()
maps_init()
enemy_init()
enemy_info_island_init()
plus_card_init()
boss_init()
level_info_island_init()
material_init()
craft_rule_init()
task_init()
randomise()

// 全局植物注册表
global.plant_registry = ds_map_create();
cards_init()

global.player_name = "Player";
global.player_sprite = noone;

load_file(global.save_slot)
//reset_file(global.save_slot)

//unlock_weapon("double_water_gun")
//unlock_weapon("ice_spoon_crossbow")
//unlock_card("chocolate_pult",12,2,7)
//unlock_card("chocolate_cannon",12,2,7)
{//测试版设置初始存档
//	unlock_card("toast_bread",6,0,5)
//	unlock_card("small_fire",6,0,5)
//	unlock_card("xiao_long_bao",6,0,5)
//	unlock_card("flour_sack",6,0,5)
//	unlock_card("double_long_bao",6,0,5)
//	unlock_card("mouse_clip",6,0,5)
//	unlock_card("coke_bomb",6,0,5)
//	unlock_card("wooden_plate",6,0,5)
//	unlock_card("ice_long_bao",6,0,5)
//	unlock_card("goblet_lamp",6,0,5)
//	unlock_card("coffee_cup",6,0,5)
//	unlock_card("salad_pult",6,0,5)
//	unlock_card("coffee_pot",6,0,5)
//	unlock_card("chocolate_bread",6,0,5)
//	unlock_card("water_tea_cup",6,0,5)
//	unlock_card("ice_bucket_bomb",6,0,5)
//	unlock_card("stinky_tofu_pult",6,0,5)
//	unlock_card("cat_box",6,0,5)
//	unlock_card("kettle_bomb",6,0,5)
//	unlock_card("fishbone",6,0,5)
//	unlock_card("triple_wine_rack",6,0,5)
//	unlock_card("brazier",6,0,5)
//	//unlock_card("large_fire",6,0,5)
//	//unlock_card("iron_fishbone",6,0,5)
//	//unlock_card("gatlin_long_bao",6,0,5)
//	//unlock_card("rotating_coffee_pot",6,0,5)
//	//unlock_card("takoyaki",6,0,5)
//	unlock_card("wine_bottle_bomb",6,0,5)
//	unlock_card("egg_boiler_pult",6,0,5)
//	unlock_card("double_water_pipe",6,0,5)
//	unlock_card("melon_shield",6,0,5)
//	//unlock_card("ice_egg_boiler_pult",6,0,5)
//	unlock_card("coffee_grounds",9,0,7)
//	unlock_card("hamburger",12,0,7)
//	unlock_card("steel_wool",6,0,5)
//	unlock_card("wooden_cork",16,0,8)
//	unlock_card("sausage",6,0,5)
//	unlock_card("oil_lamp",6,0,5)
//	unlock_card("ventilation_fan",6,0,5)
//	global.save_data.player.gold = 20000000
//	global.save_data.player.level = 15
//	global.save_data.unlocked_items.max_card_level = 6
//	global.save_data.unlocked_items.max_skill_level = 5
//	global.save_data.unlocked_items.max_gem_level = 5
//	global.save_data.unlocked_items.max_slot = 12
//	global.save_data.unlocked_items.shovel = "copper"

//	unlock_weapon("star_gun")
//	unlock_weapon("ice_gun")
//	//unlock_weapon("cat_gun")
//	//unlock_weapon("mighty_gun")
//	unlock_weapon("steel_claw_gun")
//	unlock_weapon("bubble_gun")
//	unlock_weapon("cookie_shield")
//	unlock_weapon("oreo_shield")
//	//unlock_weapon("cut_cake_shield")
//	//unlock_weapon("howitzer")
//	//unlock_weapon("enhanced_howitzer")
//	unlock_gem("attack_gem")
//	unlock_gem("laser_gem")
//	unlock_gem("bomb_gem")
//	unlock_gem("cateye_gem")
//	unlock_gem("freeze_gem")
//	//unlock_gem("starlight_gem")
//	//unlock_gem("flame_recover_gem")
//	unlock_gem("health_gem")
//	unlock_gem("produce_gem")
//	unlock_gem("slow_down_gem")
//	//unlock_gem("bleed_gem")
//	//unlock_gem("guard_gem")
//	//unlock_gem("strength_gem")
//	//unlock_gem("power_gem")
//	//unlock_gem("gale_gem")
//	//unlock_gem("transform_gem")
//	edit_gem_max_level("attack_gem",5)
//	edit_gem_max_level("health_gem",10)

//	set_material_amount("natural_spices",2000)
//	set_material_amount("secret_spices",5000)
//	set_material_amount("royal_spices",10000)
//	set_material_amount("clover_1",100)
//	set_material_amount("clover_2",100)
//	set_material_amount("clover_3",100)
//	set_material_amount("less_crystal",2000)
//	set_material_amount("middle_crystal",5000)
//	set_material_amount("advanced_crystal",10000)
}
global.player_name = global.save_data.player.name
global.total_time = global.save_data.player.total_time

//debug相关
if global.debug{
	global.save_data.player.gold = 9999999999
	global.save_data.player.level = 80
//	global.save_data.unlocked_items.max_card_level = 16
//	global.save_data.unlocked_items.max_skill_level = 8
//	global.save_data.unlocked_items.max_gem_level = 15
//	global.save_data.unlocked_items.max_slot = 21
//	global.save_data.unlocked_items.shovel = "gold"
}

room_goto(room_menu)