if global.is_paused{
	exit
}
event_inherited(); 
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

if is_frozen || state == CARD_STATE.SLEEP{
	exit
}

if is_slowdown{
	cycle = origin_cycle * 2
}
else{
	cycle = origin_cycle
}

hp_increase_card_list = []
with obj_card_parent{
	if((other.shape < 1 && abs(grid_row - other.grid_row) <= 1 && abs(grid_col - other.grid_col) <= 1)||(other.shape >= 1 && abs(grid_row - other.grid_row) <= 2 && abs(grid_col - other.grid_col) <= 2)) && id != other.id{
		array_push(other.hp_increase_card_list,id)
		if array_get_index(other.maxhp_increase_card_list,id) == -1{
			array_push(other.maxhp_increase_card_list,id)
			max_hp += other.atk
			desert_wind_protect = true
		}
	}
	else{
		if array_get_index(other.maxhp_increase_card_list,id) != -1{
			array_delete(other.maxhp_increase_card_list,array_get_index(other.maxhp_increase_card_list,id),1)
			max_hp -= other.atk
			if hp > max_hp{
				hp = max_hp
			}
			desert_wind_protect = false
		}
	}
}

if (attack_timer <= cycle - attack_anim * current_flash_speed) {
    attack_timer++;
} else if (attack_timer <= cycle) {
    attack_timer++;
    state = CARD_STATE.ATTACK;
} else {
    event_user(1); // 发射子弹
    attack_timer = 0;
    state = CARD_STATE.IDLE;
}
