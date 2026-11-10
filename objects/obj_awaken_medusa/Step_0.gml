if global.is_paused{
	exit
}

if flash_value > 0 {
	flash_value -= 10
}

if !appear{
	// 首次出场：地图右侧外（传 10）的随机行
	var enemy_pos = get_world_position_from_grid(10,irandom_range(0,global.grid_rows-1))
	x = enemy_pos.x - 90
	y = enemy_pos.y + 30
	image_alpha = 1
	timer = 0
	state = BOSS_STATE.APPEAR
	appear = true
}

// 死亡处理
if (hp <= 0 && state != BOSS_STATE.DEATH) {
	global.save_data.player.gold += 1500
	timer = 0;
	state = BOSS_STATE.DEATH;
	target_plant = noone;  // 清除攻击目标
	// 技能3 提速期间被击杀：立刻还原全场移速
	release_speedup()
	with obj_battle{
		if boss_count <= 1 && current_wave >= total_wave - 1{
			timer_pause = true
		}
	}
}

switch state{
	case BOSS_STATE.IDLE:
		sprite_index = spr_awaken_medusa_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if timer >= wait_time{
			timer = 0
			state = BOSS_STATE.DISAPPEAR
		}
		break

	case BOSS_STATE.APPEAR:
		// 到位后的待机，一轮动画播完再按循环决定放哪个技能
		sprite_index = spr_awaken_medusa_idle
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if timer == 12 * 5 - 1{
			timer = 0
			if skill_count == 0{
				state = BOSS_STATE.SKILL1
			}
			else if skill_count == 1{
				state = BOSS_STATE.SKILL2
			}
			else{
				state = BOSS_STATE.SKILL3
			}
			skill_count ++
			if skill_count >= 3{
				skill_count = 0
			}
		}
		break

	case BOSS_STATE.SKILL1:
		// 技能1：向前方三行各射出一颗穿透子弹
		sprite_index = spr_awaken_medusa_skill_1
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod skill1_anim_frames
		}
		else{
			image_index = floor(timer/5) mod skill1_anim_frames + skill1_anim_frames
		}

		if timer == skill1_fire_time{
			// 以自身所在行为中心，上下各一行（共三行）各发一颗
			var _center_row = clamp(grid_row,0,global.grid_rows-1)
			for(var _r = _center_row - skill1_rows ; _r <= _center_row + skill1_rows ; _r++){
				if _r >= 0 && _r < global.grid_rows{
					var _row_y = get_world_position_from_grid(0,_r).y
					var _bullet = instance_create_depth(x-70,_row_y+30,depth-1,obj_awaken_medusa_bullet)
					_bullet.row = _r
					_bullet.damage = skill1_damage
					_bullet.move_speed = skill1_bullet_speed
				}
			}
		}

		if timer >= skill1_anim_frames * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break

	case BOSS_STATE.SKILL2:
		// 技能2：全场冰封（1 基第 1-6 列），复用美杜莎的石像外观
		sprite_index = spr_awaken_medusa_skill_2
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod skill2_anim_frames
		}
		else{
			image_index = floor(timer/5) mod skill2_anim_frames + skill2_anim_frames
		}

		if timer == skill2_freeze_time_point{
			with obj_card_parent{
				if grid_col >= other.skill2_col_min && grid_col <= other.skill2_col_max &&
				plant_id != "player" && plant_type != "coffee" && plant_type != "lilypad" && !invincible && plant_id != "cotton_candy"{
					// 冰冻时长不做加法：低于 600 帧的直接补到 600 帧
					if frozen_timer < other.skill2_freeze_time{
						frozen_timer = other.skill2_freeze_time
					}
					// 被冰封的卡片换用石像外观
					is_medusa_statue = true
					medusa_statue_timer = other.skill2_freeze_time
					medusa_statue_anim = 0
				}
			}
		}

		if timer >= skill2_anim_frames * 5 - 1{
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break

	case BOSS_STATE.SKILL3:
		// 技能3：准备动画 -> 施法（全场回血 + 提速）-> 返回动画
		if timer < skill3_ready_time{
			sprite_index = spr_awaken_medusa_skill_3_ready
			if hp > maxhp * hurt_rate{
				image_index = floor(timer/5) mod 10
			}
			else{
				image_index = floor(timer/5) mod 10 + 10
			}
		}
		else if timer < skill3_ready_time + skill3_cast_time{
			if timer == skill3_ready_time{
				apply_heal_and_speedup()
			}
			sprite_index = spr_awaken_medusa_skill_3
			var _cast_timer = timer - skill3_ready_time
			if hp > maxhp * hurt_rate{
				image_index = floor(_cast_timer/5) mod 23
			}
			else{
				image_index = floor(_cast_timer/5) mod 23 + 23
			}
		}
		else{
			sprite_index = spr_awaken_medusa_skill_3_return
			var _back_timer = timer - skill3_ready_time - skill3_cast_time
			if hp > maxhp * hurt_rate{
				image_index = floor(_back_timer/5) mod 5
			}
			else{
				image_index = floor(_back_timer/5) mod 5 + 5
			}
		}

		// 返回动画播完：还原全场移速，回到待机
		if timer >= skill3_ready_time + skill3_cast_time + skill3_return_time - 1{
			release_speedup()
			jump_times = 0
			timer = 0
			state = BOSS_STATE.IDLE
		}
		break

	case BOSS_STATE.DISAPPEAR:
		// 移动：按 skill_count 决定下一个技能的站位与朝向
		sprite_index = spr_awaken_medusa_move
		if hp > maxhp * hurt_rate{
			image_index = floor(timer/5) mod 12
		}
		else{
			image_index = floor(timer/5) mod 12 + 12
		}
		if timer == 1{
			var enemy_row = irandom_range(0,global.grid_rows-1)
			var enemy_pos = {}
			if skill_count == 1{
				// 技能2：第 0 列（传 0，落在 1 基第 1 列的左侧），随机行
				enemy_pos = get_world_position_from_grid(0,enemy_row)
			}
			else if skill_count == 0{
				// 技能1：第 9 列（落点带 -90，传 9 实际站到 1 基的第 9 列），第 2-6 行随机
				enemy_row = clamp(irandom_range(1,5),0,global.grid_rows-1)
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			else{
				// 技能3：第 9 列随机行
				enemy_pos = get_world_position_from_grid(9,enemy_row)
			}
			x_move_speed = (enemy_pos.x - 90 - x)/180
			y_move_speed = (enemy_pos.y + 30 - y)/180
		}
		if timer >= 1 && timer <= 180{
			x += x_move_speed
			y += y_move_speed
		}
		if timer == 180{
			if skill_count == 1{
				image_xscale = -1.8	// 到左侧后翻面朝向卡片
			}
			else{
				image_xscale = 1.8	// 回到右侧，翻回原朝向
			}
			timer = 0
			state = BOSS_STATE.APPEAR
		}
		break

	case BOSS_STATE.DEATH:
		sprite_index = spr_awaken_medusa_death
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