if global.is_paused{
	exit
}

var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}

event_inherited();

if is_frozen{
	exit
}

if frozen_timer > 0{
	exit
}

with obj_card_parent{
	if grid_row >= other.grid_row && grid_col == other.grid_col && plant_id == "lightning_baguette" && !is_parent &&other.id != id{
		other.is_parent = true
		other.banding_bread = id
	}
}

if !instance_exists(banding_bread){
	is_parent = false
	banding_bread = noone
}
else{
	if is_parent{
		banding_bread.attack_timer = attack_timer
	}
}


if is_parent{

	if (attack_timer <= cycle - attack_anim * current_flash_speed) {
	    attack_timer++;
	}  else if (attack_timer == cycle - 20) {
	    event_user(1); // 发射子弹
		attack_timer++;
	}else if (attack_timer <= cycle) {
	    attack_timer++;
	    state = CARD_STATE.ATTACK;
	}else {
	    if shape == 2{
			event_user(1); // 发射子弹
		}
	    attack_timer = 0;
	    state = CARD_STATE.IDLE;
	}
}
else{
	if (attack_timer <= cycle - attack_anim * current_flash_speed) {
	    //attack_timer++;
	}  else if (attack_timer == cycle - 5) {
	    //event_user(1); // 发射子弹
		//attack_timer++;
	}else if (attack_timer <= cycle) {
	    //attack_timer++;
	    state = CARD_STATE.ATTACK;
	}else {
	    //if shape == 2{
		//	event_user(1); // 发射子弹
		//}
	    //attack_timer = 0;
	    state = CARD_STATE.IDLE;
	}
}