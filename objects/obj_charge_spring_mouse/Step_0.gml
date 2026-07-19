// Inherit the parent event

if shield_hp > 0 && state != ENEMY_STATE.ACTING{
	sprite_index = spr_charge_spring_mouse_shield
	move_speed = 0.6
}
else if shield_hp <= 0 && state != ENEMY_STATE.ACTING{
	sprite_index = spr_charge_spring_mouse
	move_speed = 0.3
}
if shield_hp <= 0 && not placed && not armor_dropped{
	var inst = instance_create_depth(x-35,y-45,depth-1,obj_enemy_armor)
	inst.ground_y = y - 30
	inst.type = "shield"
	inst.x_speed = -move_speed
	inst.y_speed = random_range(-1,-3)
	inst.cgravity = 0.8
	inst.sprite_index = spr_mouse_spring_2
	armor_dropped = true
}
event_inherited();
if global.is_paused or is_frozen or is_stun or scare_timer > 0{
	exit
}
if state == ENEMY_STATE.ATTACK && (array_get_index(can_place_list,target_plant.plant_id) != -1) && !placed && shield_hp > 0{
	sprite_index = spr_charge_spring_mouse_place
	timer = 0
	state = ENEMY_STATE.ACTING
}
if not placed && state = ENEMY_STATE.ACTING{
	if hp <= 0{
		timer = 0
		state = ENEMY_STATE.DEAD
		sprite_index = spr_charge_spring_mouse
	}
	if shield_hp <= 0{
		timer = 0
		state = ENEMY_STATE.NORMAL
		sprite_index = spr_charge_spring_mouse
	}
	if hp > maxhp * hurt_rate{
		if shield_hp > shield_max_hp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 13
		}
		else{
			image_index = floor(timer/flash_speed) mod 13 + 13
		}
	}
	else{
		if shield_hp > shield_max_hp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 13 + 26
		}
		else{
			image_index = floor(timer/flash_speed) mod 13 + 39
		}
	}
	if timer >= flash_speed * 6 or hp <= 0{
		if hp > 0 && instance_exists(target_plant){
			var spring = instance_create_depth(x-50,y-15,depth,obj_mouse_spring)
			if shield_hp <= hurt_rate * shield_max_hp{
				spring.sprite_index = spr_mouse_spring_2
			}
		}
		sprite_index = spr_charge_spring_mouse
		state = ENEMY_STATE.NORMAL
		shield_hp = 0
		placed = true
	}
}