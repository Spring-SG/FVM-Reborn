if global.is_paused{
	exit
}

if hp <= 0.33*max_hp{
	sprite_index = spr_cat_chest_3
}
else if hp <= 0.66*max_hp{
	sprite_index = spr_cat_chest_2
}
else{
	sprite_index = spr_cat_chest_1
}
event_inherited(); 
if is_frozen{
	exit
}
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
//检测自身右方是否有敌人
var has_enemy = false
for(var i = 0; i < array_length(scared_enemy) ; i++){
	array_delete(scared_enemy,0,1)
}
with(obj_enemy_parent){
	if (grid_row == other.grid_row && grid_col >= other.grid_col && grid_col <= (other.grid_col + 1) && hp > 0 && can_target_on(other.target_type,target_type)){
		array_push(other.scared_enemy,id)
		has_enemy = true
	}
}
if current_hp != hp && has_enemy{
	state = CARD_STATE.ATTACK
	timer = 0
}
if state == CARD_STATE.ATTACK{
	if attack_timer == 20{
		if has_enemy{
			event_user(1)
		}
	}
	
	attack_timer++
	if attack_timer >= current_flash_speed * attack_anim{
		state = CARD_STATE.IDLE
		attack_timer = 0
		timer = 0
	}
}

current_hp = hp
