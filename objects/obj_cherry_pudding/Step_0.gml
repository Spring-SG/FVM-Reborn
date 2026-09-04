if global.is_paused{
	exit
}
event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

if is_frozen || !is_cookbook_equipped("pineapple_pudding"){
	exit
}

if current_hp > hp{
	bleed_damage = current_hp - hp
	event_user(1)
}

current_hp = hp
if frozen_timer > 0{
	exit
}

attack_timer++

if is_slowdown{
	heal_wait = 120
}
else{
	heal_wait = 60
}

if attack_timer mod heal_wait == 0{
	if hp < max_hp - 10{
		hp += 10
		instance_create_depth(x,y+30,depth-4,obj_card_heal_effect)
	}
	else if hp < max_hp{
		hp = max_hp
		instance_create_depth(x,y+30,depth-4,obj_card_heal_effect)
	}
	current_hp = hp
	attack_timer = 0
}
