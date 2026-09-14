// Inherit the parent event

if shield_hp > 0 && state != ENEMY_STATE.ACTING{
	sprite_index = spr_repairman_mouse_shield
	move_anim = 8
	attack_anim = 5
	move_speed = 0.6
}
else if shield_hp <= 0 && state != ENEMY_STATE.ACTING{
	sprite_index = spr_repairman_mouse
	move_anim = 8
	attack_anim = 4
	move_speed = 0.3
}
if shield_hp <= 0 && not placed && not armor_dropped{
	var inst = instance_create_depth(x-35,y-75,depth-1,obj_enemy_armor)
	inst.ground_y = y - 30
	inst.type = "shield"
	inst.x_speed = random_range(-3,-5)
	inst.y_speed = random_range(-1,-3)
	inst.cgravity = 0.8
	inst.sprite_index = spr_ladder_shield
	armor_dropped = true
}
event_inherited();
if global.is_paused or is_frozen{
	exit
}
if state == ENEMY_STATE.ATTACK && instance_exists(target_plant) && !placed && shield_hp > 0{
	if array_get_index(can_place_list,target_plant.plant_id) != -1{
		sprite_index = spr_repairman_mouse_place
		timer = 0
		state = ENEMY_STATE.ACTING
	}
}
if not placed && state = ENEMY_STATE.ACTING{
	if hp <= 0{
		timer = 0
		state = ENEMY_STATE.DEAD
		sprite_index = spr_repairman_mouse
	}
	if shield_hp <= 0{
		timer = 0
		state = ENEMY_STATE.NORMAL
		sprite_index = spr_repairman_mouse
	}
	if hp > maxhp * hurt_rate{
		if shield_hp > shield_max_hp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 6
		}
		else{
			image_index = floor(timer/flash_speed) mod 6 + 5
		}
	}
	else{
		if shield_hp > shield_max_hp * hurt_rate{
			image_index = floor(timer/flash_speed) mod 6 + 11
		}
		else{
			image_index = floor(timer/flash_speed) mod 6 + 17
		}
	}
	if timer >= flash_speed * 6 or hp <= 0{
		if hp > 0 && instance_exists(target_plant){
			instance_create_depth(x-50,y-37,depth,obj_ladder)
		}
		sprite_index = spr_repairman_mouse
		state = ENEMY_STATE.NORMAL
		shield_hp = 0
		placed = true
	}
}