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
map_object_init()
attire_init()
//battle_event_init()
cookbook_init()
randomise()

// 全局植物注册表
global.plant_registry = ds_map_create();
cards_init()

global.player_name = "Player";
global.total_time = 0
global.player_sprite = noone;

load_file(global.save_slot)
//reset_file(global.save_slot)


global.player_name = global.save_data.player.name
global.total_time = global.save_data.player.total_time

var screen_width = display_get_width()/1920
var screen_height = display_get_height()/1080
window_set_size(1920*0.8*screen_width,1080*0.8*screen_width)

global.gui_stack.to(room_menu)
