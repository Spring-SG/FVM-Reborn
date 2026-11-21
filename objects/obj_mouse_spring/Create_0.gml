image_xscale = 1.8
image_yscale = 1.8
image_speed = 0

timer = 0
attack_timer = 0
row = -1
col = -1

enemy_list = []
enemy_left_time = []

state = "idle"

ignore_list = ["mario_mouse","mario_pipeline","arno","pharaoh_coffin","temple_pharaoh","ice_residue","ice_residue_ball","abyss_pharaoh","pink_paul","paul_tentacle","blonde_mary","pete","pete_claw","pete_spike",
				"rowboat_mouse","barrier","hells_messenger","messenger_mace","messenger_poop","fog_julie","lieutenant_buzz","barrier","needle_baron","baron_bats","irritable_jack","irritable_jack_rock",
				"hot_vajra","hot_vajra_spike","paratrooper_mouse_shield","huang_xiaoming","angelababy","angelababy_diamond","mouse_train_1","captain_america_mouse","captain_rainbow","iron_man_mouse","iron_man",
				"mouse_train_2","spider_man_mouse","hulk_mouse","mouse_train_3","mermaid_mary","mermaid_wave","machine_shark_1","lobster_knight","electric_jellyfish","jellyfish_bullet","war_god",
				"war_god_duck","war_god_wood","hercules","thor","travel_record","beverage_machine","face_cookie","witch_shaman_mouse","hermit_crab_mouse","medusa",
				"tribal_chief_mouse","awaken_medusa","ufo_mouse","anubis_mouse"
]

left_use_times = 5