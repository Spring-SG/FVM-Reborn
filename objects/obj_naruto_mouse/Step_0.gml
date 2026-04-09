// Inherit the parent event
if dash{
	move_speed = 1.2
	sprite_index = spr_naruto_mouse_summon
	move_anim = 6
	if hp <= 0{
		move_anim = 12
		dash = false
	}
}
else{
	if state == ENEMY_STATE.ACTING{
		sprite_index = spr_naruto_mouse_summon
	}
	else{
		sprite_index = spr_naruto_mouse
	}
}
event_inherited();
if global.is_paused or is_frozen or is_stun{
	exit
}
if summon_cooldown > 0 {summon_cooldown--}
if dash && (state == ENEMY_STATE.ATTACK or timer > 4.5*60){
	move_speed = 0.27
	move_anim = 12
	dash = false
	timer = 0
	state = ENEMY_STATE.ACTING
	
	if target_plant != noone{
		with (target_plant) {
			if !invincible{
				hp -= 50;
			}
	        event_user(2)
	        // 播放受击效果

	        //播放音效
			var a = irandom_range(0,2)
			audio_play_sound(ds_list_find_value(obj_battle.chomp_sound_list,a),0,0)
		}
	}
}
if state == ENEMY_STATE.ACTING{
	if hp <= 0{
		timer = 0
		sprite_index = spr_naruto_mouse
		state = ENEMY_STATE.DEAD
	}
	if hp > maxhp * hurt_rate{
		image_index = floor(timer/flash_speed) mod 16 + 12
	}
	else{
		image_index = floor(timer/flash_speed) mod 16 + 27
	}
	if timer >= flash_speed * 16 or hp <= 0{
		if hp > 0{
			if !instance_exists(inst_left){
				inst_left = instance_create_depth(x-100,y,depth,obj_naruto_minion_mouse)
			}
			if !instance_exists(inst_right){
				inst_right = instance_create_depth(x+100,y,depth,obj_naruto_minion_mouse)
			}
			if grid_row > 0 && !instance_exists(inst_up){
				if global.row_feature[clamp(grid_row - 1,0,global.grid_rows - 1)] != "water"{
					inst_up = instance_create_depth(x,y-global.grid_cell_size_y,depth,obj_naruto_minion_mouse)
				}
			}
			if grid_row < global.grid_rows - 1 && !instance_exists(inst_down){
				if global.row_feature[clamp(grid_row + 1,0,global.grid_rows - 1)] != "water"{
					inst_down = instance_create_depth(x,y+global.grid_cell_size_y,depth,obj_naruto_minion_mouse)
				}
			}
			
		}
		state = ENEMY_STATE.NORMAL
		sprite_index = spr_naruto_mouse
	}
	summon_cooldown = 900
}
if (!instance_exists(inst_left) || !instance_exists(inst_right) || (!instance_exists(inst_up) && grid_row > 0) || (!instance_exists(inst_down) && grid_row < global.grid_rows - 1)) && summon_cooldown <= 0 && state != ENEMY_STATE.DEAD && state != ENEMY_STATE.ACTING{
	if (!instance_exists(inst_left) || !instance_exists(inst_right) || !instance_exists(inst_up) && global.row_feature[clamp(grid_row - 1,0,global.grid_rows - 1)] != "water") || (!instance_exists(inst_down) && global.row_feature[clamp(grid_row + 1,0,global.grid_rows - 1)] != "water"){
		timer = 0
		state = ENEMY_STATE.ACTING
	}
}