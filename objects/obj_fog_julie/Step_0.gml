if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	var enemy_row = 0
	var enemy_pos = {}
	if skill_count == 2{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	else if skill_count == 0{
		enemy_pos = get_world_position_from_grid(10,enemy_row)
	}
	else{
		enemy_pos = get_world_position_from_grid(9,enemy_row)
	}
	x = enemy_pos.x - 80
	y = enemy_pos.y + 30
	image_alpha = 0
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	if instance_exists(banding_summon_obj){
		banding_summon_obj.hp = 0
	}
	global.save_data.player.gold += 3000
    timer = 0;
    state = BOSS_STATE.DEATH;
    target_plant = noone;  // 清除攻击目标
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		sprite_index = idle_spr
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod idle_anim
		}
		else{
			image_index = floor(timer/5) mod idle_anim + idle_anim
		}
		if timer >= wait_time{
			timer = 0
			if skill_count == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL4
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 3{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 4{
				state = BOSS_STATE.SKILL4
			}
			skill_count ++
			if skill_count >= 5{
				skill_count = 0
			}
			break
		}
		break
		
	case BOSS_STATE.APPEAR:
		sprite_index = spr_fog_julie_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		image_alpha = timer/50
		if timer == 10 * 5 - 1{
			image_alpha = 1
			timer = 0
			if skill_count == 0 {
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL4
			}
			else if skill_count == 2{
				state = BOSS_STATE.SKILL2
			}
			else if skill_count == 3{
				state = BOSS_STATE.SKILL3
			}
			else if skill_count == 4{
				state = BOSS_STATE.SKILL4
			}
			skill_count ++
			if skill_count >= 5{
				skill_count = 0
			}
			break
		}
		break
	
	case BOSS_STATE.SKILL1:
		sprite_index = spr_fog_julie_skill_1
		
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if !fog_summoned{
			y_move_speed = (6*global.grid_cell_size_y)/240
			y += y_move_speed
		}
		else{
			if timer == 1{
				t_pos = get_world_position_from_grid(9,irandom_range(0,global.grid_rows-1))
			
				y_move_speed = (t_pos.y+33-y)/240
				x_move = (t_pos.x-90-x)/240
			}
			if timer > 1{
				x += x_move
				y += y_move_speed
			}
		}
		if timer mod 30 == 0 && jump_times < 7 && !fog_summoned{
			
			for(var j = 6 ; j < global.grid_cols+3;j++){
				var pos = get_world_position_from_grid(j,jump_times)
				var fog = instance_create_depth(pos.x+10,pos.y-50,-800,obj_fog)
				fog.col = j
				fog.row = jump_times
				fog.image_alpha = 0
			}
			jump_times ++
		}
		
		if timer >= 240{
			fog_summoned = true
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL4:
		
		
		
		if timer <= 120{
			sprite_index = spr_fog_julie_idle
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 12
			}
			else{
				image_index = floor(timer /5) mod 12 + 12
			}
		}
		else{
			sprite_index = spr_fog_julie_skill_4
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-120) /5) mod 12
			}
			else{
				image_index = floor((timer-120) /5) mod 12 + 12
			}
		}
		
		
		if timer == 1{
			
			t_pos = get_world_position_from_grid(irandom_range(3,7),irandom_range(0,global.grid_rows-1))
			
			y_move_speed = (t_pos.y+33-y)/120
			x_move = (t_pos.x-90-x)/120
		}
		if timer == 150{
			var inst = instance_create_depth(x,y-75,-800,obj_julie_missile)
			inst.target_row = grid_row
			inst.target_col = grid_col
		}
		if timer > 1 && timer <= 120{
			x += x_move
			y += y_move_speed
		}
		if timer >= 120 + 12 * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.SKILL3:
		
		if timer <= 120{
			sprite_index = spr_fog_julie_idle
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 12
			}
			else{
				image_index = floor(timer /5) mod 12 + 12
			}
		}
		else if timer <= (120 + 17 * 5 - 1){
			sprite_index = spr_fog_julie_skill_2_ready
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-120) /5) mod 17
			}
			else{
				image_index = floor((timer-120) /5) mod 17 + 17
			}
		}
		else{
			sprite_index = spr_fog_julie_skill_3
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-205) /5) mod 19
			}
			else{
				image_index = floor((timer-205) /5) mod 19 + 19
			}
		}
		
		if timer > 205 && timer mod 95 == 45{
			with obj_enemy_parent{
				if hp > 0{
					if maxhp < 600{
						maxhp = 600
					}
					if hp <= maxhp - 600{
						hp += 600
					}
					else{
						hp = maxhp
					}
					var inst = instance_create_depth(x,y-45,depth-1,obj_card_heal_effect)
					inst.sprite_index = spr_mouse_heal_effect
				}
			}
		}
		
		if timer == 1{
			
			t_pos = get_world_position_from_grid(9,irandom_range(0,global.grid_rows-1))
			
			y_move_speed = (t_pos.y+33-y)/120
			x_move = (t_pos.x-90-x)/120
		}
		if timer > 1 && timer <= 120{
			x += x_move
			y += y_move_speed
		}
		
		if timer >= 120 + 17 * 5 + 19 * 2 * 5 - 1{
			idle_spr = spr_fog_julie_skill_2_idle
			idle_anim = 10
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
	case BOSS_STATE.SKILL2:
		
		if timer <= (38 * 5 - 1){
			sprite_index = spr_fog_julie_skill_2
			if hp > maxhp * hurt_rate{
				image_index = floor(timer /5) mod 38
			}
			else{
				image_index = floor(timer /5) mod 38 + 38
			}
		}
		else{
			sprite_index = spr_fog_julie_skill_2_return
			if hp > maxhp * hurt_rate{
				image_index = floor((timer-190) /5) mod 18
			}
			else{
				image_index = floor((timer-190) /5) mod 18 + 18
			}
		}
		
		if timer == 19 * 5{
			if !instance_exists(banding_summon_obj){
				var enemy_row = irandom_range(0,global.grid_rows-1)
				var enemy_pos = get_world_position_from_grid(8,enemy_row)
				banding_summon_obj = instance_create_depth(enemy_pos.x-80,enemy_pos.y+33,-200,obj_lieutenant_buzz)
				obj_battle.boss_count++
				if global.level_id != "macchiato_port"{
					banding_summon_obj.maxhp = 2500 * maxhp/50000
					banding_summon_obj.hp = banding_summon_obj.maxhp
					banding_summon_obj.skill_count = 2
				}
			}
		}
		
		if timer >= 190+18*5-1{
			idle_spr = spr_fog_julie_idle
			idle_anim = 12
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break
		
	case BOSS_STATE.DISAPPEAR:
		sprite_index = spr_pete_disappear
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 13
		}
		else{
			image_index = floor(timer/5) mod 13 + 13
		}
		if timer == 13 * 5 - 1{
			image_alpha = 0
		}
		if timer == 240{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 2{
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else if skill_count == 0{
				enemy_pos = get_world_position_from_grid(irandom_range(2,6),enemy_row)
			}
			else{
				enemy_pos = get_world_position_from_grid(6,enemy_row)
			}
			x = enemy_pos.x - 80
			y = enemy_pos.y + 30
			image_alpha = 1
			timer = 0
			state = BOSS_STATE.APPEAR
			break
		}
		break
	
	case BOSS_STATE.DEATH:
		sprite_index = spr_fog_julie_death
		image_index = floor(timer/5) mod image_number
		if timer >= image_number * 5{
			image_alpha -= 0.1
			image_index = image_number - 1
		}
		break
}


timer ++


// 透明度处理
if (image_alpha <= 0 && state == BOSS_STATE.DEATH) {
    instance_destroy();
}


var zombie_grid = get_grid_position_from_world(x, y);

// 更新僵尸的网格位置和深度

var base_depth = -10 - (zombie_grid.row * 45) - (zombie_grid.col * 5);
depth = base_depth - 4.5; // 僵尸比植物稍微靠后一点（在护罩外侧和咖啡豆之间）

// 保持网格位置更新

grid_col = zombie_grid.col;
grid_row = zombie_grid.row;

