// Inherit the parent event
if (grid_col < 0 || grid_col >= global.grid_cols || grid_row < 0 || grid_row >= global.grid_rows) {
	if hp > maxhp - helmet_hp{
		sprite_index = spr_egg_tropical_fish_mouse_land_helmet
	}
	else{
		sprite_index = spr_egg_tropical_fish_mouse_land
	}
	death_anim = 12
}
else{
	if global.grid_terrains[grid_row][grid_col].type == "water"{
		if sprite_index == spr_egg_tropical_fish_mouse_land or sprite_index == spr_egg_tropical_fish_mouse_land_helmet{
			state = ENEMY_STATE.ACTING
			sprite_index = spr_egg_tropical_fish_mouse_enter
			timer = 0
			audio_play_sound(snd_enter_water,0,0)
			reversed = false
		}
		
		death_anim = 9
	}
	else{
		if sprite_index == spr_egg_tropical_fish_mouse or sprite_index == spr_egg_tropical_fish_mouse_helmet{
			state = ENEMY_STATE.ACTING
			sprite_index = spr_egg_tropical_fish_mouse_enter
			timer = 0
			audio_play_sound(snd_enter_water,0,0)
			reversed = true
		}
		
		death_anim = 12
	}
	if hp > maxhp - helmet_hp && state != ENEMY_STATE.ACTING{
		if global.grid_terrains[grid_row][grid_col].type == "water"{
			sprite_index = spr_egg_tropical_fish_mouse_helmet
		}
		else{
			sprite_index = spr_egg_tropical_fish_mouse_land_helmet
		}
	}
	else if hp <= maxhp - helmet_hp && state != ENEMY_STATE.ACTING{
		if global.grid_terrains[grid_row][grid_col].type == "water"{
			sprite_index = spr_egg_tropical_fish_mouse
		}
		else{
			sprite_index = spr_egg_tropical_fish_mouse_land
		}
	}
}
if hp <= maxhp - helmet_hp && not armor_dropped{
	var inst = instance_create_depth(x-45,y-175,depth-1,obj_enemy_armor)
	if sprite_index == spr_egg_tropical_fish_mouse || sprite_index == spr_egg_tropical_fish_mouse_helmet{
		inst.y += 30
		inst.water = true
	}
	inst.ground_y = y - 45
	inst.type = "helmet"
	inst.x_speed = random_range(3,5)
	inst.y_speed = random_range(-5,-8)
	inst.cgravity = 0.8
	inst.sprite_index = spr_pan_helmet
	armor_dropped = true
}
event_inherited();
if global.is_paused or is_frozen{
	exit
}
if state = ENEMY_STATE.ACTING{
	if hp > maxhp - helmet_hp{
				sprite_index = spr_egg_tropical_fish_mouse_enter_helmet
			}
			else{
				sprite_index = spr_egg_tropical_fish_mouse_enter
			}
	x -= move_speed
	if hp > maxhp * hurt_rate{
		if reversed{
			image_index = 8 - (floor(timer/flash_speed) mod 8)
		}
		else{
			image_index = floor(timer/flash_speed) mod 8
		}
	}
	else{
		if reversed{
			image_index = 8 - (floor(timer/flash_speed) mod 8) + 8
		}
		else{
			image_index = (floor(timer/flash_speed) mod 8) + 8
		}
	}
	if timer >= flash_speed * 8 or hp <= 0{
		state = ENEMY_STATE.NORMAL
		if reversed{
			if hp > maxhp - helmet_hp{
				sprite_index = spr_egg_tropical_fish_mouse_land_helmet
			}
			else{
				sprite_index = spr_egg_tropical_fish_mouse_land
			}
		}
		else{
			if hp > maxhp - helmet_hp{
				sprite_index = spr_egg_tropical_fish_mouse_helmet
			}
			else{
				sprite_index = spr_egg_tropical_fish_mouse
			}
		}
	}
}
if hp > maxhp - helmet_hp{
	hit_sound = snd_hit3
}
else{
	hit_sound = snd_hit1
}